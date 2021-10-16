#!/bin/bash

# Includes
source _helpers.sh
source _common.sh

declare -r AZURE_SP_JSON="azuresp.json"
declare -r DETAILS_FILE="details.json"

if [ -f "devvars.sh" ]; then
    source devvars.sh
fi

if [ ! -f "${DETAILS_FILE}" ]; then
    _error "${DETAILS_FILE} does not exist!"
    exit 1
fi

if [ ! -f "${AZURE_SP_JSON}" ]; then
    _error "${AZURE_SP_JSON} does not exist!"
    exit 1
fi

# Check for GITHUB_TOKEN
if [ -z ${GITHUB_TOKEN+x} ]; then
    _error "GITHUB_TOKEN does not set!"
    exit 1
fi

# Check for programs
declare -a commands=("az" "jq" "gh")
check_commands "${commands[@]}"

# Read details file
_json=$(cat "${DETAILS_FILE}")
ORG_NAME=$(echo "${_json}" | jq -c -r '.orgName')
TEAM_NAME=$(echo "${_json}" | jq -c -r '.teamName')

# https://docs.github.com/en/rest/reference/teams#delete-a-team
_information "Removing ${ORG_NAME}/${TEAM_NAME} repository..."
gh api "repos/${ORG_NAME}/${TEAM_NAME}" -X DELETE

# https://docs.github.com/en/rest/reference/repos#delete-a-repository
_information "Removing ${ORG_NAME}/${TEAM_NAME} team..."
gh api "orgs/${ORG_NAME}/teams/${TEAM_NAME}" -X DELETE

export GITHUB_TOKEN=0

_information "Removing Azure resources..."
delete_azure_resources "${TEAM_NAME}"

_success "Done!"