# OpsGility Automation Requires ARM Templates

The ARM templates are given to OpsGility admins to deploy to each team's sub.

## ARM Template Resources For Containersv2 OH

This ARM template deploys the image provided in the parameters to a Linux Azure Container Instance.

## DevOps Pipeline Instructions

This pipeline will create three different resources groups as part of the testing process.
- teamDeploy
    - Resource group containing an ACI instance with the newly built teamDeploy image.
- teamResources
    - Resource group created by teamDeploy, containing necessary resources for OpenHack attendees.
- ProctorVMRG
    - Resource group create by teamDeploy, containing the VM for the proctor, for the OpenHack challenge content.

- Create an ACR
- Create a service principal to give ACR pull access

```

ACR_NAME=containersv2
ACR_REGISTRY_ID=$(az acr show --name $ACR_NAME --query id --output tsv)
SP_PASSWD=$(az ad sp create-for-rbac --name http://$SERVICE_PRINCIPAL_NAME --scopes $ACR_REGISTRY_ID --role acrpull --query password --output tsv)
SP_APP_ID=$(az ad sp show --id http://$SERVICE_PRINCIPAL_NAME --query appId --output tsv)

echo "Service principal ID: $SP_APP_ID"
echo "Service principal password: $SP_PASSWD"

```

- Create a Key Vault, make sure that it is enabled for template deployment
- Reference service principal secrets in deployment file as "securestring"
    - https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-manager-keyvault-parameter