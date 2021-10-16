#!/bin/bash

# Includes
source _helpers.sh
source _common.sh

declare AZURE_LOCATION=""
declare GITHUB_ORG_NAME="CSE-OpenHackContent"
declare TEAM_NAME=""
declare AZURE_DEPLOYMENT=true

declare -r GITHUB_API_ENDPOINT="https://api.github.com"
declare -r GITHUB_TEMPLATE_OWNER="Azure-Samples"
declare -r GITHUB_TEMPLATE_REPO="openhack-devops-team"
declare -r NAME_PREFIX="devopsoh"
declare -r USAGE_HELP="Usage: ./deploy-gh.sh -l <AZURE_LOCATION> [-o <GITHUB_ORG_NAME> -t <TEAM_NAME> -a <AZURE_DEPLOYMENT> true/false]"
declare -r AZURE_SP_JSON="azuresp.json"
declare -r DETAILS_FILE="details.json"
declare -r BUILD_ID=$(head -3 /dev/urandom | tr -cd '[:digit:]' | cut -c -4)

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
    o) # Process -o (GitHub Organization)
        GITHUB_ORG_NAME="${OPTARG}"
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

declare -a unsupported_azure_regions=("koreasouth" "westindia" "australiacentral")
if [[ "${unsupported_azure_regions[*]}" =~ "${AZURE_LOCATION}" ]]; then
    _error "Provided region (${AZURE_LOCATION}) is not supported."
    _error "Unsupported regions:"
    printf '%s\n' "${unsupported_azure_regions[@]}"
    exit 1
fi

if [ ${#GITHUB_ORG_NAME} -eq 0 ]; then
    _error "Required GITHUB_ORG_NAME parameter is not set!"
    _error "${USAGE_HELP}"
    exit 1
fi

# Check for GITHUB_TOKEN
if [ -z ${GITHUB_TOKEN+x} ]; then
    _error "GITHUB_TOKEN does not set!"
    exit 1
fi

# Check for programs
declare -a commands=("az" "jq" "gh" "curl")
check_commands "${commands[@]}"
check_tool_semver "azure-cli" $(az version --output tsv --query \"azure-cli\") "2.29.0"

# Call GitHub API helper
_gh_call_api() {
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
_gh_create_templatebase_repository() {
    local _templatebase_repository_name="$1"

    _api_path="/repos/${GITHUB_TEMPLATE_OWNER}/${GITHUB_TEMPLATE_REPO}/generate"
    _api_uri="${GITHUB_API_ENDPOINT}${_api_path}"
    _api_body='{"owner": "'"${GITHUB_ORG_NAME}"'","name": "'"${_templatebase_repository_name}"'", "description": "Repo for '"${_templatebase_repository_name}"'", "include_all_branches": true, "private": true}'

    _gh_call_api "POST" "${_api_uri}" "${_api_body}" "baptiste-preview"
}

# https://docs.github.com/en/rest/reference/repos#update-a-repository
_gh_update_repository() {
    local _repository_full_name="$1"

    _api_path="/repos/${_repository_full_name}"
    _api_uri="${GITHUB_API_ENDPOINT}${_api_path}"
    _api_body='{"has_issues": true, "has_projects": true, "has_wiki": true, "has_issues": true}'

    _gh_call_api "PATCH" "${_api_uri}" "${_api_body}" "nebula-preview"
}

gh_create_organization_repository() {
    local _organization_repositor_name="$1"

    _templatebase_repository=$(_gh_create_templatebase_repository "${_organization_repositor_name}")
    _repository_full_name=$(echo "${_templatebase_repository}" | jq -c -r '.full_name')
    _organization_repository=$(_gh_update_repository "${_repository_full_name}")

    echo "${_organization_repository}"
}

# CREATE A TEAM
# https://docs.github.com/en/rest/reference/teams#create-a-team
gh_create_team() {
    local _team_name="$1"
    local _repository_full_name="$2"

    _api_path="/orgs/${GITHUB_ORG_NAME}/teams"
    _api_uri="${GITHUB_API_ENDPOINT}${_api_path}"
    _api_body='{"name": "'"${_team_name}"'", "description": "Team for '"${_team_name}"'", "repo_names": ["'"${_repository_full_name}"'"] ,"privacy": "secret"}'

    _gh_call_api "POST" "${_api_uri}" "${_api_body}"
}

# UPDATE TEAM REPOSITORY PERMISSIONS
# https://docs.github.com/en/rest/reference/teams#add-or-update-team-repository-permissions
gh_update_team_repository_permissions() {
    local _team_slug="$1"
    local _repository_full_name="$2"
    local _team_permission="$3"

    _api_path="/orgs/${GITHUB_ORG_NAME}/teams/${_team_slug}/repos/${_repository_full_name}"
    _api_uri="${GITHUB_API_ENDPOINT}${_api_path}"
    _api_body='{"permission": "'"${_team_permission}"'"}'

    _gh_call_api "PUT" "${_api_uri}" "${_api_body}"
}

# CREATE A REPOSITORY PROJECT
# https://docs.github.com/en/rest/reference/projects#create-a-repository-project
gh_create_repository_project() {
    local _repository_project_name="$1"
    local _repository_full_name="$2"

    _api_path="/repos/${_repository_full_name}/projects"
    _api_uri="${GITHUB_API_ENDPOINT}${_api_path}"
    _api_body='{"name": "'"${_repository_project_name}"'", "body": "Repo Project for '"${_repository_project_name}"'"}'

    _gh_call_api "POST" "${_api_uri}" "${_api_body}"
}

# CREATE REPOSITORY SECRET
_gh_create_repository_secret() {
    local _repository_secret_name="$1"
    local _repository_full_name="$2"
    local _value="$3"

    gh secret set "${_repository_secret_name}" -b "${_value}" --repo "${_repository_full_name}"
}

gh_create_repository_secrets(){
    local _organization_repository_fullname="$1"

    _azure_parse_json

    _gh_create_repository_secret "ACTIONS_RUNNER_DEBUG" "${_organization_repository_fullname}" "false"
    _gh_create_repository_secret "RESOURCES_PREFIX" "${_organization_repository_fullname}" "${UNIQUE_NAME}"
    _gh_create_repository_secret "LOCATION" "${_organization_repository_fullname}" "${AZURE_LOCATION}"
    _gh_create_repository_secret "TFSTATE_RESOURCES_GROUP_NAME" "${_organization_repository_fullname}" "${UNIQUE_NAME}staterg"
    _gh_create_repository_secret "TFSTATE_STORAGE_ACCOUNT_NAME" "${_organization_repository_fullname}" "${UNIQUE_NAME}statest"
    _gh_create_repository_secret "TFSTATE_STORAGE_CONTAINER_NAME" "${_organization_repository_fullname}" "tfstate"
    _gh_create_repository_secret "TFSTATE_KEY" "${_organization_repository_fullname}" "terraform.tfstate"
    _gh_create_repository_secret "AZURE_CREDENTIALS" "${_organization_repository_fullname}" "$(cat azuresp.json)"
    _gh_create_repository_secret "ARM_CLIENT_ID" "${_organization_repository_fullname}" "${ARM_CLIENT_ID}"
    _gh_create_repository_secret "ARM_CLIENT_SECRET" "${_organization_repository_fullname}" "${ARM_CLIENT_SECRET}"
    _gh_create_repository_secret "ARM_SUBSCRIPTION_ID" "${_organization_repository_fullname}" "${ARM_SUBSCRIPTION_ID}"
    _gh_create_repository_secret "ARM_TENANT_ID" "${_organization_repository_fullname}" "${ARM_TENANT_ID}"
}

gh_logout(){
    export GITHUB_TOKEN=0
}

save_details(){
    local _project_url="$1"
    local _team_url="$2"
    local _repo_url="$3"

    jq -n \
        --arg teamName "${UNIQUE_NAME}" \
        --arg projectUrl "${_project_url}" \
        --arg teamUrl "${_team_url}" \
        --arg repoUrl "${_repo_url}" \
        --arg azRgTfState "https://portal.azure.com/#resource/subscriptions/${ARM_SUBSCRIPTION_ID}/resourceGroups/${UNIQUE_NAME}staterg/overview" \
        '{teamName: $teamName, projectUrl: $projectUrl, teamUrl: $teamUrl, repoUrl: $repoUrl, azRgTfState: $azRgTfState}' > "${DETAILS_FILE}"
}

# EXECUTE
_information "Getting unique name..."
get_unique_name

_information "Checking for ${AZURE_SP_JSON} file..."
check_azuresp_json

_information "Creating Azure resources..."
create_azure_resources

_information "Creating organization repository..."
organization_repository=$(gh_create_organization_repository "${UNIQUE_NAME}")
_organization_repository_fullname=$(echo "${organization_repository}" | jq -c -r '.full_name')

_information "Creating GitHub team..."
team=$(gh_create_team "${UNIQUE_NAME}" "${_organization_repository_fullname}")

_information "Updating team repository permissions..."
_team_slug=$(echo "${team}" | jq -c -r '.slug')
team_repository_permissions=$(gh_update_team_repository_permissions "${_team_slug}" "${_organization_repository_fullname}" "admin")

_information "Creating repository project..."
repository_project=$(gh_create_repository_project "${UNIQUE_NAME}" "${_organization_repository_fullname}")

_information "Creating repository secrets..."
gh_create_repository_secrets "${_organization_repository_fullname}"

_information "GitHub logout..."
gh_logout

_team_url=$(echo "${team}" | jq -c -r '.html_url')
_repository_url=$(echo "${organization_repository}" | jq -c -r '.html_url')
_project_url=$(echo "${repository_project}" | jq -c -r '.html_url')

_information "Saving details to ${DETAILS_FILE} file..."
save_details "${_project_url}" "${_team_url}" "${_repository_url}"

# OUTPUT
echo -e "\n"
_information "Team Name: ${UNIQUE_NAME}"
_information "Project URL: ${_project_url}"
_information "Team URL: ${_team_url}"
_information "Repo URL: ${_repository_url}"
_information "Azure RG for TF State: https://portal.azure.com/#resource/subscriptions/${ARM_SUBSCRIPTION_ID}/resourceGroups/${UNIQUE_NAME}staterg/overview"
echo -e "\n"
_success "Done!"
