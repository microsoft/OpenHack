#!/bin/bash

declare AZURE_LOCATION=""
declare ADO_ORG_NAME=""
declare TEAM_NAME=""

declare -r ADO_ENDPOINT="https://dev.azure.com"
declare -r REPO_TEMPLATE="https://github.com/Azure-Samples/openhack-devops-team"
declare -r NAME_PREFIX="devopsoh"
declare -r USAGE_HELP="Usage: ./deploy-gh.sh -l <AZURE_LOCATION> -o <ADO_ORG_NAME> [-t <TEAM_NAME>]"

# Helpers
_information() {
    echo "##[command] $@"
}

_error() {
    echo "##[error] $@" 2>&1
}

_debug() {
    if [ ${DEBUG_FLAG} == true ]; then
        echo "##[debug] $@"
    fi
}

# Verify the type of input and number of values
# Display an error message if the input is not correct
# Exit the shell script with a status of 1 using exit 1 command.
if [ $# -eq 0 ]; then
    _error "${USAGE_HELP}"
    exit 1
fi

# Initialize parameters specified from command line
while getopts ":l:o:t:" arg; do
    case "${arg}" in
    l) # Process -l (Location)
        AZURE_LOCATION="${OPTARG}"
        ;;
    o) # Process -o (Azure DevOps Organization)
        ADO_ORG_NAME="${OPTARG}"
        ;;
    t) # Process -t (Team Name)
        TEAM_NAME=$(echo "${OPTARG}" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')
        ;;
    \?)
        _error "Invalid options found: -${OPTARG}."
        _error "${USAGE_HELP}" 2>&1
        exit 1
        ;;
    esac
done
shift $((OPTIND - 1))

if [ ${#AZURE_LOCATION} -eq 0 ]; then
    _error "Required AZURE_LOCATION parameter is not set!"
    _error "${USAGE_HELP}" 2>&1
    exit 1
fi

if [ ${#ADO_ORG_NAME} -eq 0 ]; then
    _error "Required ADO_ORG_NAME parameter is not set!"
    _error "${USAGE_HELP}" 2>&1
    exit 1
fi

# Check for programs
if ! [ -x "$(command -v az)" ]; then
    _error "az is not installed!"
    exit 1
elif ! [ -x "$(command -v jq)" ]; then
    _error "jq is not installed!"
    exit 1
fi

check_tool_semver() {
    local _tool_name="$1"
    local _tool_ver="$2"
    local _tool_min_ver="$3"

    _semver=$(./semver2.sh "${_tool_ver}" "${_tool_min_ver}")

    if [ "${_semver}" -lt 0 ]; then
        _error "${_tool_name} version ${_tool_ver} is lower then required! Expected minimum ${_tool_min_ver}"
        exit 1
    fi
}

check_tool_semver "azure-cli" $(az version --output tsv --query \"azure-cli\") "2.28.0"

_azdevopsver=$(az extension show --only-show-errors --name azure-devops --output tsv --query version)

if [ "${#_azdevopsver}" -eq 0 ]; then
    az extension add --name azure-devops
else
    _semver=$(./semver2.sh "${_azdevopsver}" "0.20.0")
    if [ "${_semver}" -lt 0 ]; then
        az extension update --name azure-devops
    fi
fi

if [ -f "devvars.sh" ]; then
    . devvars.sh
fi

# Check for AZURE_DEVOPS_EXT_PAT
if [ -z ${AZURE_DEVOPS_EXT_PAT+x} ]; then
    _error "AZURE_DEVOPS_EXT_PAT does not set!"
    exit 1
fi

if [ ${#TEAM_NAME} -eq 0 ]; then
    # Generate unique name
    UNIQUER=$(head -3 /dev/urandom | tr -cd '[:digit:]' | cut -c -5)
    UNIQUE_NAME="${NAME_PREFIX}${UNIQUER}"
else
    UNIQUE_NAME="${NAME_PREFIX}${TEAM_NAME}"
fi

# AZURE AUTH
# Check for azuresp.json
AZURE_SP_JSON="azuresp.json"
if [ ! -f "${AZURE_SP_JSON}" ]; then
    az ad sp create-for-rbac --sdk-auth --role Contributor > azuresp.json
fi

_azure_login() {
    _azuresp_json=$(cat azuresp.json)
    export ARM_CLIENT_ID=$(echo "${_azuresp_json}" | jq -r ".clientId")
    export ARM_CLIENT_SECRET=$(echo "${_azuresp_json}" | jq -r ".clientSecret")
    export ARM_SUBSCRIPTION_ID=$(echo "${_azuresp_json}" | jq -r ".subscriptionId")
    export ARM_TENANT_ID=$(echo "${_azuresp_json}" | jq -r ".tenantId")
    az login --service-principal --username "${ARM_CLIENT_ID}" --password "${ARM_CLIENT_SECRET}" --tenant "${ARM_TENANT_ID}"
    az account set --subscription "${ARM_SUBSCRIPTION_ID}"
}

_azure_logout() {
    az logout
    az cache purge
    az account clear
}

# AZURE RESOURCES
create_azure_resources() {
    local _azure_resource_name="$1"

    _azure_login

    az bicep install
    _sp_object_id=$(az ad sp show --id "${ARM_CLIENT_ID}" --query objectId --output tsv)
    az deployment sub create --name "${UNIQUE_NAME}" --location "${AZURE_LOCATION}" --template-file azure.bicep --parameters uniquer="${UNIQUE_NAME}" spPrincipalId="${_sp_object_id}"

    _azure_logout
}

# AZURE DEVOPS

# ado_login(){
#     echo  "${AZURE_DEVOPS_EXT_PAT}" | az devops login --organization "${ADO_ENDPOINT}/${ADO_ORG_NAME}"
# }

ado_config_defaults(){
    az devops configure --defaults organization="${ADO_ENDPOINT}/${ADO_ORG_NAME}" project="${UNIQUE_NAME}"
}

ado_project_create(){
    az devops project create --name "${UNIQUE_NAME}" --visibility private --process Basic
}

ado_repo_import(){
    az repos import create --repository "${UNIQUE_NAME}" --git-source-url "${REPO_TEMPLATE}"
    az repos update --repository "${UNIQUE_NAME}" --default-branch main
}

ado_extensions_install(){
    az devops extension install --publisher-id "charleszipp" --extension-id "azure-pipelines-tasks-terraform"
}

ado_serviceconnection_create(){
    _azure_login

    ARM_SUBSCRIPTION_NAME=$(az account show --output tsv --query name)
    export AZURE_DEVOPS_EXT_AZURE_RM_SERVICE_PRINCIPAL_KEY="${ARM_CLIENT_SECRET}"
    az devops service-endpoint azurerm create --name "AzureServiceConnection" --azure-rm-service-principal-id "${ARM_CLIENT_ID}" --azure-rm-subscription-id "${ARM_SUBSCRIPTION_ID}" --azure-rm-subscription-name "${ARM_SUBSCRIPTION_NAME}" --azure-rm-tenant-id "${ARM_TENANT_ID}"
    # TODO: Grant access permission to all pipelines

    _azure_logout
}

ado_variablegroup_create(){
    az pipelines variable-group create --name "openhack" --variables \
        LOCATION="${AZURE_LOCATION}" \
        RESOURCES_PREFIX="${UNIQUE_NAME}"
    az pipelines variable-group create --name "tfstate" --variables \
        TFSTATE_RESOURCES_GROUP_NAME="${UNIQUE_NAME}staterg" \
        TFSTATE_STORAGE_ACCOUNT_NAME="${UNIQUE_NAME}statest" \
        TFSTATE_STORAGE_CONTAINER_NAME="tfstate" \
        TFSTATE_KEY="terraform.tfstate"
}

ado_logout(){
    # az devops logout
    export AZURE_DEVOPS_EXT_PAT=0
}

save_details(){
    jq -n \
        --arg teamName "${UNIQUE_NAME}" \
        --arg projectUrl "${ADO_ENDPOINT}/${ADO_ORG_NAME}/${UNIQUE_NAME}" \
        --arg teamUrl "${ADO_ENDPOINT}/${ADO_ORG_NAME}/${UNIQUE_NAME}/_settings/teams" \
        --arg repoUrl "${ADO_ENDPOINT}/${ADO_ORG_NAME}/_git/${UNIQUE_NAME}" \
        --arg azRgTfState "https://portal.azure.com/#resource/subscriptions/${ARM_SUBSCRIPTION_ID}/resourceGroups/${UNIQUE_NAME}staterg/overview" \
        '{teamName: $teamName, projectUrl: $projectUrl, teamUrl: $teamUrl, repoUrl: $repoUrl, azRgTfState: $azRgTfState}' > details.json
}

# EXECUTE
create_azure_resources
ado_config_defaults
ado_project_create
ado_repo_import
ado_extensions_install
ado_serviceconnection_create
ado_variablegroup_create
ado_logout
save_details

# OUTPUT
echo "Team Name: ${UNIQUE_NAME}"
echo "Project URL: ${ADO_ENDPOINT}/${ADO_ORG_NAME}/${UNIQUE_NAME}"
echo "Team URL: ${ADO_ENDPOINT}/${ADO_ORG_NAME}/${UNIQUE_NAME}/_settings/teams"
echo "Repo URL: ${ADO_ENDPOINT}/${ADO_ORG_NAME}/_git/${UNIQUE_NAME}"
echo "Azure RG for TF State: https://portal.azure.com/#resource/subscriptions/${ARM_SUBSCRIPTION_ID}/resourceGroups/${UNIQUE_NAME}staterg/overview"

echo 'Done!'