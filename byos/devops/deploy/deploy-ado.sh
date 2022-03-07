#!/bin/bash

# Includes
source _helpers.sh
source _common.sh

declare AZURE_LOCATION=""
declare ADO_ORG_NAME=""
declare TEAM_NAME=""
declare AZURE_DEPLOYMENT=true

declare -r ADO_ENDPOINT="https://dev.azure.com"
declare -r REPO_TEMPLATE="https://github.com/Microsoft-OpenHack/devops-artifacts"
declare -r NAME_PREFIX="devopsoh"
declare -r USAGE_HELP="Usage: ./deploy-gh.sh -l <AZURE_LOCATION> -o <ADO_ORG_NAME> [-t <TEAM_NAME> -a <AZURE_DEPLOYMENT> true/false]"
declare -r AZURE_SP_JSON="azuresp.json"
declare -r DETAILS_FILE="details-ado.json"

if [ -f "devvars.sh" ]; then
    source devvars.sh
fi

# Verify the type of input and number of values
# Display an error message if the input is not correct
# Exit the shell script with a status of 1 using exit 1 command.
if [ $# -eq 0 ]; then
    _error "${USAGE_HELP}"
    exit 1
fi

# Initialize parameters specified from command line
while getopts ":l:o:t:a:" arg; do
    case "${arg}" in
    l) # Process -l (Location)
        AZURE_LOCATION="${OPTARG}"
        ;;
    o) # Process -o (Azure DevOps Organization)
        ADO_ORG_NAME="${OPTARG}"
        ;;
    t) # Process -t (Team Name)
        TEAM_NAME=$(echo "${OPTARG}" | LC_CTYPE=C tr '[:upper:]' '[:lower:]' | LC_CTYPE=C tr -d '[:space:]')
        ;;
    a) # Process -a (Azure Deployment)
        AZURE_DEPLOYMENT="${OPTARG}"
        ;;
    \?)
        _error "Invalid options found: -${OPTARG}."
        _error "${USAGE_HELP}"
        exit 1
        ;;
    esac
done
shift $((OPTIND - 1))

if [ ${#AZURE_LOCATION} -eq 0 ]; then
    _error "Required AZURE_LOCATION parameter is not set!"
    _error "${USAGE_HELP}"
    exit 1
fi

declare -a supported_azure_regions=("centralus" "uksouth" "eastasia" "southeastasia" "brazilsouth" "canadacentral" "southindia" "australiaeast" "westeurope" "westus2")
if [[ ! "${supported_azure_regions[*]}" =~ "${AZURE_LOCATION}" ]]; then
    _error "Provided region (${AZURE_LOCATION}) is not supported."
    _error "Supported regions:"
    printf '%s\n' "${supported_azure_regions[@]}"
    exit 1
fi

if [ ${#ADO_ORG_NAME} -eq 0 ]; then
    _error "Required ADO_ORG_NAME parameter is not set!"
    _error "${USAGE_HELP}"
    exit 1
fi

# Check for AZURE_DEVOPS_EXT_PAT
if [ -z ${AZURE_DEVOPS_EXT_PAT+x} ]; then
    _error "AZURE_DEVOPS_EXT_PAT does not set!"
    exit 1
fi

# Check for programs
declare -a commands=("az" "jq" "ssh-keygen")
check_commands "${commands[@]}"
check_tool_semver "azure-cli" $(az version --output tsv --query \"azure-cli\") "2.34.1"

_azdevopsver=$(az extension show --only-show-errors --name azure-devops --output tsv --query version)
if [ "${#_azdevopsver}" -eq 0 ]; then
    az extension add --name azure-devops
else
    _semver=$(./semver2.sh "${_azdevopsver}" "0.22.0")
    if [ "${_semver}" -lt 0 ]; then
        az extension update --name azure-devops
    fi
fi

# AZURE DEVOPS

# ado_login(){
#     echo  "${AZURE_DEVOPS_EXT_PAT}" | az devops login --organization "${ADO_ENDPOINT}/${ADO_ORG_NAME}"
# }

ado_config_defaults() {
    az devops configure --defaults organization="${ADO_ENDPOINT}/${ADO_ORG_NAME}" project="${UNIQUE_NAME}"
}

ado_project_create() {
    az devops project create --name "${UNIQUE_NAME}" --visibility private --process Agile
}

ado_repo_import() {
    az repos import create --repository "${UNIQUE_NAME}" --git-source-url "${REPO_TEMPLATE}"
    az repos update --repository "${UNIQUE_NAME}" --default-branch main
}

ado_extensions_install() {
    # az devops extension show --publisher-id "charleszipp" --extension-id "azure-pipelines-tasks-terraform" --output tsv --query version --only-show-errors; echo "$?"
    az devops extension install --publisher-id "charleszipp" --extension-id "azure-pipelines-tasks-terraform"
    az devops extension install --publisher-id "mspremier" --extension-id "CreateWorkItem"
    az devops extension install --publisher-id "CSE-DevOps" --extension-id "create-pr-comment-task"
    az devops extension install --publisher-id "Foxholenl" --extension-id "Gitleaks"
    az devops extension install --publisher-id "sariftools" --extension-id "scans"
}

ado_serviceconnection_create() {
    _azure_login

    ARM_SUBSCRIPTION_NAME=$(az account show --output tsv --query name)
    export AZURE_DEVOPS_EXT_AZURE_RM_SERVICE_PRINCIPAL_KEY="${ARM_CLIENT_SECRET}"
    id=$(az devops service-endpoint azurerm create --output tsv --query id --name "AzureServiceConnection" --azure-rm-service-principal-id "${ARM_CLIENT_ID}" --azure-rm-subscription-id "${ARM_SUBSCRIPTION_ID}" --azure-rm-subscription-name "${ARM_SUBSCRIPTION_NAME}" --azure-rm-tenant-id "${ARM_TENANT_ID}")
    az devops service-endpoint update --id ${id} --enable-for-all true

    _azure_logout
}

ado_variablegroup_create() {
    az pipelines variable-group create --name "openhack" --variables \
        LOCATION="${AZURE_LOCATION}" \
        RESOURCES_PREFIX="${UNIQUE_NAME}"
    az pipelines variable-group create --name "tfstate" --variables \
        TFSTATE_RESOURCES_GROUP_NAME="${UNIQUE_NAME}staterg" \
        TFSTATE_STORAGE_ACCOUNT_NAME="${UNIQUE_NAME}statest" \
        TFSTATE_STORAGE_CONTAINER_NAME="tfstate" \
        TFSTATE_KEY="terraform.tfstate"
}

ado_logout() {
    # az devops logout
    export AZURE_DEVOPS_EXT_PAT=0
}

# ADO VMSS Agents

deploy_adovmsswinagent() {
    declare -r WINPASS=$(head -3 /dev/urandom | LC_CTYPE=C tr -cd '[:alnum:][:punct:]' | cut -c -16)
    az deployment sub create --name "winagent${UNIQUER}-${BUILD_ID}" --location "${AZURE_LOCATION}" --template-file adovmssagent/main.bicep --parameters uniquer="${UNIQUER}" os="win" adminPasswordOrKey="${WINPASS}"
}

deploy_adovmsslnxagent() {
    prvKeyPath="$(pwd)/id_rsa"
    pubKeyPath="$(pwd)/id_rsa.pub"

    ssh-keygen -m PEM -t rsa -b 4096 -f "${prvKeyPath}" -N '' <<<$'\ny' >/dev/null 2>&1

    if [ -f "${prvKeyPath}" ] && [ -f "${pubKeyPath}" ]; then
        privateSshKey=$(<"${prvKeyPath}")
        publicSshKey=$(<"${pubKeyPath}")
    else
        echo >&2 "Provate SSH key file or public SSH key file not exist, please check!"
        exit 1
    fi
    az deployment sub create --name "lnxagent${UNIQUER}-${BUILD_ID}" --location "${AZURE_LOCATION}" --template-file adovmssagent/main.bicep --parameters uniquer="${UNIQUER}" os="lnx" adminPasswordOrKey="${publicSshKey}"
}

save_details() {
    jq -n \
        --arg teamName "${UNIQUE_NAME}" \
        --arg orgName "${ADO_ORG_NAME}" \
        --arg boardUrl "${ADO_ENDPOINT}/${ADO_ORG_NAME}/${UNIQUE_NAME}/_boards/board/t/${UNIQUE_NAME}%20Team/Stories" \
        --arg projectUrl "${ADO_ENDPOINT}/${ADO_ORG_NAME}/${UNIQUE_NAME}" \
        --arg teamUrl "${ADO_ENDPOINT}/${ADO_ORG_NAME}/${UNIQUE_NAME}/_settings/teams" \
        --arg repoUrl "${ADO_ENDPOINT}/${ADO_ORG_NAME}/_git/${UNIQUE_NAME}" \
        --arg azRgTfState "https://portal.azure.com/#resource/subscriptions/${ARM_SUBSCRIPTION_ID}/resourceGroups/${UNIQUE_NAME}staterg/overview" \
        --arg TFSTATE_RESOURCES_GROUP_NAME "${UNIQUE_NAME}staterg" \
        --arg TFSTATE_STORAGE_ACCOUNT_NAME "${UNIQUE_NAME}statest" \
        --arg TFSTATE_STORAGE_CONTAINER_NAME "tfstate" \
        --arg TFSTATE_KEY "terraform.tfstate" \
        --arg WINPASS "${WINPASS}" \
        '{teamName: $teamName, orgName: $orgName, boardUrl: $boardUrl, projectUrl: $projectUrl, teamUrl: $teamUrl, repoUrl: $repoUrl, azRgTfState: $azRgTfState, TFSTATE_RESOURCES_GROUP_NAME: $TFSTATE_RESOURCES_GROUP_NAME, TFSTATE_STORAGE_ACCOUNT_NAME: $TFSTATE_STORAGE_ACCOUNT_NAME, TFSTATE_STORAGE_CONTAINER_NAME: $TFSTATE_STORAGE_CONTAINER_NAME, TFSTATE_KEY: $TFSTATE_KEY, WINPASS: $WINPASS}' >"${DETAILS_FILE}"
}

# EXECUTE
_information "Getting unique name..."
get_unique_name

_information "Checking for ${AZURE_SP_JSON} file..."
check_azuresp_json

_information "Creating Azure resources..."
create_azure_resources

_information "Configuring ADO defaults..."
ado_config_defaults

_information "Configuring ADO project..."
ado_project_create

_information "Importing template repo..."
ado_repo_import

_information "instaling ADO extensions..."
ado_extensions_install

_information "Creating ADO service connecton..."
ado_serviceconnection_create

_information "Creating ADO variable groups..."
ado_variablegroup_create

_information "ADO logout..."
ado_logout

_information "Deploying ADO VMSS Windows Agent..."
deploy_adovmsswinagent

_information "Deploying ADO VMSS Linux Agent..."
deploy_adovmsslnxagent

_information "Saving details to ${DETAILS_FILE} file..."
save_details

# OUTPUT
echo -e "\n"
_information "Team Name: ${UNIQUE_NAME}"
_information "Project URL: ${ADO_ENDPOINT}/${ADO_ORG_NAME}/${UNIQUE_NAME}"
_information "Team URL: ${ADO_ENDPOINT}/${ADO_ORG_NAME}/${UNIQUE_NAME}/_settings/teams"
_information "Repo URL: ${ADO_ENDPOINT}/${ADO_ORG_NAME}/_git/${UNIQUE_NAME}"
_information "Azure RG for TF State: https://portal.azure.com/#resource/subscriptions/${ARM_SUBSCRIPTION_ID}/resourceGroups/${UNIQUE_NAME}staterg/overview"
echo -e "\n"
_success "Done!"
