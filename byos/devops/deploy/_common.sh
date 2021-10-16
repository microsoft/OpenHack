check_azuresp_json() {
    if [ ! -f "${AZURE_SP_JSON}" ]; then
        az ad sp create-for-rbac --sdk-auth --role Owner > "${AZURE_SP_JSON}"
        # wait for the token to sync across aad
        sleep 60
    fi
}

_azure_parse_json() {
    _azuresp_json=$(cat "${AZURE_SP_JSON}")
    export ARM_CLIENT_ID=$(echo "${_azuresp_json}" | jq -c -r '.clientId')
    export ARM_CLIENT_SECRET=$(echo "${_azuresp_json}" | jq -c -r '.clientSecret')
    export ARM_SUBSCRIPTION_ID=$(echo "${_azuresp_json}" | jq -c -r '.subscriptionId')
    export ARM_TENANT_ID=$(echo "${_azuresp_json}" | jq -c -r '.tenantId')
}

_azure_login() {
    _azure_parse_json
    az login --service-principal --username "${ARM_CLIENT_ID}" --password "${ARM_CLIENT_SECRET}" --tenant "${ARM_TENANT_ID}"
    az account set --subscription "${ARM_SUBSCRIPTION_ID}"
}

_azure_logout() {
    az logout
    az cache purge
    az account clear
}

create_azure_resources() {
    declare -r BUILD_ID=$(head -3 /dev/urandom | tr -cd '[:digit:]' | cut -c -4)
    if [ ${AZURE_DEPLOYMENT} == true ]; then
        _azure_login

        az bicep upgrade
        _sp_object_id=$(az ad sp show --id "${ARM_CLIENT_ID}" --query objectId --output tsv)
        az deployment sub create --name "${UNIQUE_NAME}-${BUILD_ID}" --location "${AZURE_LOCATION}" --template-file azure.bicep --parameters resourcesPrefix="${UNIQUE_NAME}" spPrincipalId="${_sp_object_id}"

        _azure_logout
    fi
}

get_unique_name() {
    if [ ${#TEAM_NAME} -eq 0 ]; then
        # Generate unique name
        UNIQUER=$(head -3 /dev/urandom | LC_CTYPE=C tr -cd '[:digit:]' | cut -c -5)
        UNIQUE_NAME="${NAME_PREFIX}${UNIQUER}"
    else
        UNIQUE_NAME="${NAME_PREFIX}${TEAM_NAME}"
    fi
}
