#!/bin/bash

declare AZURE_LOCATION=""
declare GITHUB_ORG_NAME="CSE-OpenHackContent"
declare TEAM_NAME=""
declare -r GITHUB_API_ENDPOINT="https://api.github.com"
declare -r GITHUB_TEMPLATE_OWNER="Azure-Samples"
declare -r GITHUB_TEMPLATE_REPO="openhack-devops-team"
declare -r NAME_PREFIX="devopsoh"
declare -r USAGE_HELP="Usage: ./deploy-gh.sh -l <AZURE_LOCATION> [-g <GITHUB_ORG_NAME> -t <TEAM_NAME>]"

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
while getopts ":l:g:t:" arg; do
    case "${arg}" in
    l) # Process -l (Location)
        AZURE_LOCATION="${OPTARG}"
        ;;
    g) # Process -g (GitHub Organization)
        GITHUB_ORG_NAME="${OPTARG}"
        ;;
    t) # Process -t (Team Name)
        TEAM_NAME="${OPTARG}"
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

# Check for programs
if ! [ -x "$(command -v az)" ]; then
    _error "az is not installed!"
    exit 1
elif ! [ -x "$(command -v jq)" ]; then
    _error "jq is not installed!"
    exit 1
elif ! [ -x "$(command -v gh)" ]; then
    _error "gh is not installed!"
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

if [ -f "devvars.sh" ]; then
    . devvars.sh
fi

# Check for GITHUB_TOKEN
if [ -z ${GITHUB_TOKEN+x} ]; then
    _error "GITHUB_TOKEN does not set!"
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
    az ad sp create-for-rbac --sdk-auth --role Owner >azuresp.json
fi

_parse_azuresp_json() {
    _azuresp_json=$(cat azuresp.json)
    export ARM_CLIENT_ID=$(echo "${_azuresp_json}" | jq -r ".clientId")
    export ARM_CLIENT_SECRET=$(echo "${_azuresp_json}" | jq -r ".clientSecret")
    export ARM_SUBSCRIPTION_ID=$(echo "${_azuresp_json}" | jq -r ".subscriptionId")
    export ARM_TENANT_ID=$(echo "${_azuresp_json}" | jq -r ".tenantId")
}

_azure_login() {
    _parse_azuresp_json
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
    az deployment sub create --location "${AZURE_LOCATION}" --template-file azure.bicep --parameters uniquer="${UNIQUE_NAME}" spPrincipalId="${_sp_object_id}"

    _azure_logout
}

# Call GitHub API helper
call_gh_api() {
    local _api_request_type="$1"
    local _api_uri="$2"
    local _api_body="$3"
    local _api_preview="$4"

    if [ -n "${_api_preview}" ]; then
        _accept_header="application/vnd.github.${_api_preview}+json"
    else
        _accept_header="application/vnd.github.v3+json"
    fi

    if [ "${_api_request_type}" == "GET" ]; then
        _response=$(curl --silent --compressed --location --request "${_api_request_type}" \
            --header "Accept: ${_accept_header}" \
            --header 'Content-Type: application/json; charset=utf-8' \
            --header "Authorization: token ${GITHUB_TOKEN}" \
            "${_api_uri}")
    else
        _response=$(curl --silent --compressed --location --request "${_api_request_type}" \
            --header "Accept: ${_accept_header}" \
            --header 'Content-Type: application/json; charset=utf-8' \
            --header "Authorization: token ${GITHUB_TOKEN}" \
            "${_api_uri}" \
            --data-raw "${_api_body}")
    fi

    echo "${_response}"
}

# CREATE AN ORGANIZATION REPOSITORY
# https://docs.github.com/en/rest/reference/repos#create-a-repository-using-a-template
_create_templatebase_repository() {
    local _templatebase_repository_name="$1"

    _api_path="/repos/${GITHUB_TEMPLATE_OWNER}/${GITHUB_TEMPLATE_REPO}/generate"
    _api_uri="${GITHUB_API_ENDPOINT}${_api_path}"
    _api_body='{"owner": "'"${GITHUB_ORG_NAME}"'","name": "'"${_templatebase_repository_name}"'", "description": "Repo for '"${_templatebase_repository_name}"'", "include_all_branches": true, "private": true}'

    call_gh_api "POST" "${_api_uri}" "${_api_body}" "baptiste-preview"
}

# https://docs.github.com/en/rest/reference/repos#update-a-repository
_update_repository() {
    local _repository_full_name="$1"

    _api_path="/repos/${_repository_full_name}"
    _api_uri="${GITHUB_API_ENDPOINT}${_api_path}"
    _api_body='{"has_issues": true, "has_projects": true, "has_wiki": true, "has_issues": true}'

    call_gh_api "PATCH" "${_api_uri}" "${_api_body}" "nebula-preview"
}

create_organization_repository() {
    local _organization_repositor_name="$1"

    _templatebase_repository=$(_create_templatebase_repository "${_organization_repositor_name}")
    _repository_full_name=$(echo "${_templatebase_repository}" | jq -c -r '.full_name')
    _organization_repository=$(_update_repository "${_repository_full_name}")

    echo "${_organization_repository}"
}

# CREATE A TEAM
# https://docs.github.com/en/rest/reference/teams#create-a-team
create_team() {
    local _team_name="$1"
    local _repository_full_name="$2"

    _api_path="/orgs/${GITHUB_ORG_NAME}/teams"
    _api_uri="${GITHUB_API_ENDPOINT}${_api_path}"
    _api_body='{"name": "'"${_team_name}"'", "description": "Team for '"${_team_name}"'", "repo_names": ["'"${_repository_full_name}"'"] ,"privacy": "secret"}'

    call_gh_api "POST" "${_api_uri}" "${_api_body}"
}

# UPDATE TEAM REPOSITORY PERMISSIONS
# https://docs.github.com/en/rest/reference/teams#add-or-update-team-repository-permissions
update_team_repository_permissions() {
    local _team_slug="$1"
    local _repository_full_name="$2"
    local _team_permission="$3"

    _api_path="/orgs/${GITHUB_ORG_NAME}/teams/${_team_slug}/repos/${_repository_full_name}"
    _api_uri="${GITHUB_API_ENDPOINT}${_api_path}"
    _api_body='{"permission": "'"${_team_permission}"'"}'

    call_gh_api "PUT" "${_api_uri}" "${_api_body}"
}

# CREATE A REPOSITORY PROJECT
# https://docs.github.com/en/rest/reference/projects#create-a-repository-project
create_repository_project() {
    local _repository_project_name="$1"
    local _repository_full_name="$2"

    _api_path="/repos/${_repository_full_name}/projects"
    _api_uri="${GITHUB_API_ENDPOINT}${_api_path}"
    _api_body='{"name": "'"${_repository_project_name}"'", "body": "Repo Project for '"${_repository_project_name}"'"}'

    call_gh_api "POST" "${_api_uri}" "${_api_body}"
}

# CREATE REPOSITORY SECRET
create_repository_secret() {
    local _repository_secret_name="$1"
    local _repository_full_name="$2"
    local _value="$3"

    gh auth login --with-token "${GITHUB_TOKEN}"
    gh secret set "${_repository_secret_name}" -b "${_value}" --repo "${_repository_full_name}"
}

# EXECUTE
create_azure_resources "${UNIQUE_NAME}"
organization_repository=$(create_organization_repository "${UNIQUE_NAME}")
_organization_repository_fullname=$(echo "${organization_repository}" | jq -c -r '.full_name')
team=$(create_team "${UNIQUE_NAME}" "${_organization_repository_fullname}")
_team_slug=$(echo "${team}" | jq -c -r '.slug')
team_repository_permissions=$(update_team_repository_permissions "${_team_slug}" "${_organization_repository_fullname}" "admin")
repository_project=$(create_repository_project "${UNIQUE_NAME}" "${_organization_repository_fullname}")
create_repository_secret "RESOURCES_PREFIX" "${_organization_repository_fullname}" "${UNIQUE_NAME}"
create_repository_secret "LOCATION" "${_organization_repository_fullname}" "${AZURE_LOCATION}"
create_repository_secret "TFSTATE_RESOURCES_GROUP_NAME" "${_organization_repository_fullname}" "${UNIQUE_NAME}staterg"
create_repository_secret "TFSTATE_STORAGE_ACCOUNT_NAME" "${_organization_repository_fullname}" "${UNIQUE_NAME}statest"
create_repository_secret "TFSTATE_STORAGE_CONTAINER_NAME" "${_organization_repository_fullname}" "tfstate"
create_repository_secret "TFSTATE_KEY" "${_organization_repository_fullname}" "terraform.tfstate"
create_repository_secret "AZURE_CREDENTIALS" "${_organization_repository_fullname}" "$(cat azuresp.json)"

# OUTPUT
_team_url=$(echo "${team}" | jq -c -r '.html_url')
_repository_url=$(echo "${organization_repository}" | jq -c -r '.html_url')
_project_url=$(echo "${repository_project}" | jq -c -r '.html_url')

echo "Team Name: ${UNIQUE_NAME}"
echo "Team URL: ${_team_url}"
echo "Repo URL: ${_repository_url}"
echo "Project URL: ${_project_url}"
echo "Azure RG: https://portal.azure.com/#resource/subscriptions/${ARM_SUBSCRIPTION_ID}/resourceGroups/${UNIQUE_NAME}staterg/overview"
