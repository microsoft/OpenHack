#!/bin/bash

# Includes
source _helpers.sh
source _common.sh
source _gh.sh

declare COMMA_SEPARATED_USERS_EMAILS=""
declare USER_ROLE="direct_member"
declare GITHUB_ORG_NAME="DevOpsOpenHack"

declare DEBUG_FLAG=true
declare -r USAGE_HELP='Usage: ./invite-gh.sh -u "<COMMA_SEPARATED_USERS_EMAILS>" [-r <USER_ROLE> -o <GITHUB_ORG_NAME>]'

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
while getopts ":u:r:o:" arg; do
    case "${arg}" in
    u) # Process -u (Users)
        COMMA_SEPARATED_USERS_EMAILS="${OPTARG}"
        ;;
    r) # Process -r (Role)
        USER_ROLE="${OPTARG}"
        ;;
    o) # Process -o (GitHub Organization)
        GITHUB_ORG_NAME="${OPTARG}"
        ;;
    \?)
        _error "Invalid options found: -${OPTARG}."
        _error "${USAGE_HELP}"
        exit 1
        ;;
    esac
done
shift $((OPTIND - 1))

declare -a supported_gh_roles=("direct_member" "admin")
if [[ ! "${supported_gh_roles[*]}" =~ "${USER_ROLE}" ]]; then
    _error "Provided role (${USER_ROLE}) is not supported."
    _error "Supported roles:"
    printf '%s\n' "${supported_gh_roles[@]}"
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
declare -a commands=("jq" "curl")
check_commands "${commands[@]}"

# https://docs.github.com/en/rest/reference/orgs#create-an-organization-invitation
_gh_sent_invite() {
    local _gh_user_email="$1"
    local _gh_user_role="$2"

    if [ ${#_gh_user_role} -eq 0 ]; then
        _gh_user_role="direct_member"
    fi

    _api_path="/orgs/${GITHUB_ORG_NAME}/invitations"
    _api_uri="${GITHUB_API_ENDPOINT}${_api_path}"
    _api_body='{"email": "'"${_gh_user_email}"'", "role": "'"${_gh_user_role}"'"}'

    _gh_call_api "POST" "${_api_uri}" "${_api_body}"
}

emails=($(echo "${COMMA_SEPARATED_USERS_EMAILS}" | tr "," "\n"))
for email in "${emails[@]}"; do
    _information "Inviting : ${email}"
    _debug_json $(_gh_sent_invite "${email}" "${USER_ROLE}")
done
