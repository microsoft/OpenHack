check_azuresp_json() {
    if [ ! -f "${AZURE_SP_JSON}" ]; then
        export ARM_SUBSCRIPTION_ID=$(az account show --output tsv --query id)
        az ad sp create-for-rbac --role Owner --scopes "/subscriptions/${ARM_SUBSCRIPTION_ID}" --output json >"${AZURE_SP_JSON}"

        # workaround for --sdk-auth deprecation to keep backwards compatibility
        _azuresp_json=$(cat "${AZURE_SP_JSON}")
        export ARM_CLIENT_ID=$(echo "${_azuresp_json}" | jq -c -r '.appId')
        export ARM_CLIENT_SECRET=$(echo "${_azuresp_json}" | jq -c -r '.password')
        export ARM_TENANT_ID=$(echo "${_azuresp_json}" | jq -c -r '.tenant')

        echo "${_azuresp_json}" | jq \
            --arg clientId "${ARM_CLIENT_ID}" \
            --arg clientSecret "${ARM_CLIENT_SECRET}" \
            --arg subscriptionId "${ARM_SUBSCRIPTION_ID}" \
            --arg tenantId "${ARM_TENANT_ID}" \
            --arg activeDirectoryEndpointUrl "https://login.microsoftonline.com" \
            --arg resourceManagerEndpointUrl "https://management.azure.com/" \
            --arg activeDirectoryGraphResourceId "https://graph.windows.net/" \
            --arg sqlManagementEndpointUrl "https://management.core.windows.net:8443/" \
            --arg galleryEndpointUrl "https://gallery.azure.com/" \
            --arg managementEndpointUrl "https://management.core.windows.net/" \
            '.clientId = $clientId | .clientSecret = $clientSecret | .subscriptionId = $subscriptionId | .tenantId = $tenantId | .activeDirectoryEndpointUrl = $activeDirectoryEndpointUrl | .resourceManagerEndpointUrl = $resourceManagerEndpointUrl | .activeDirectoryGraphResourceId = $activeDirectoryGraphResourceId | .sqlManagementEndpointUrl = $sqlManagementEndpointUrl | .galleryEndpointUrl = $galleryEndpointUrl | .managementEndpointUrl = $managementEndpointUrl' >"${AZURE_SP_JSON}"

        # wait for the token to sync across aad
        sleep 60
    fi
}

_azure_parse_json() {
    _azuresp_json=$(cat "${AZURE_SP_JSON}")
    export ARM_CLIENT_ID=$(echo "${_azuresp_json}" | jq -c -r '.appId')
    export ARM_CLIENT_SECRET=$(echo "${_azuresp_json}" | jq -c -r '.password')
    export ARM_SUBSCRIPTION_ID=$(echo "${_azuresp_json}" | jq -c -r '.subscriptionId')
    export ARM_TENANT_ID=$(echo "${_azuresp_json}" | jq -c -r '.tenant')
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
    declare -r BUILD_ID=$(head -3 /dev/urandom | LC_CTYPE=C tr -cd '[:digit:]' | cut -c -4)
    if [ ${AZURE_DEPLOYMENT} == true ]; then
        _azure_login

        az bicep upgrade
        _sp_object_id=$(az ad sp show --id "${ARM_CLIENT_ID}" --query objectId --output tsv)
        az deployment sub create --name "${UNIQUE_NAME}-${BUILD_ID}" --location "${AZURE_LOCATION}" --template-file azure.bicep --parameters resourcesPrefix="${UNIQUE_NAME}" spPrincipalId="${_sp_object_id}"

        _azure_logout
    fi
}

delete_azure_resources() {
    local _resources_prefix="$1"

    _azure_login

    az group delete --resource-group "${_resources_prefix}rg" --yes --no-wait
    az group delete --resource-group "${_resources_prefix}staterg" --yes --no-wait

    _azure_logout
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
