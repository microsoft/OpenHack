#!/bin/sh

deviceLogin=false
verbose=false
manualPat=false

while getopts u:p:s:t:dvm flag
do
    case "${flag}" in
        u) username=${OPTARG};;
        p) password=${OPTARG};;
        s) subscription=${OPTARG};;
        t) tenant=${OPTARG};;
        d) deviceLogin=true;;
        v) verbose=true;;
        m) manualPat=true;;
    esac
done

if [ "$verbose" = true ]
then
    set -x;
fi

# Variables
rand="$((1 + $RANDOM % 100000000))"
rbac="rbacDeploy$rand"
devops="devopsDeploy$rand"

cd /deploy

echo "Cleaning authorization remnants..."
rm -f ./oh.azureauth

echo "Logging into Azure via CLI and setting subscription ($subscription)..."
if [ "$deviceLogin" = true ]
then
    az login --use-device-code --output none --allow-no-subscriptions
else
    az login -u $username -p $password --output none --allow-no-subscriptions --only-show-errors
fi
az account set --subscription $subscription

echo "Creating RBAC identity ($rbac) for deployment service principal..."
az ad sp create-for-rbac --only-show-errors --name $rbac --role Contributor --sdk-auth > oh.azureauth

if [ "$manualPat" = false ]
then
    echo "Creating managed app ($devops) for generating Azure DevOps PAT token..."
    az ad app create --display-name $devops --native-app --required-resource-accesses @/source/azdo/manifest.json --output none

    # Wait 60 seconds to ensure that Azure has successfully created service princpals
    sleep 60

    appId=$(az ad app list --display-name $devops --query [0].appId)
    appId="${appId%\"}"
    appId="${appId#\"}"
    az ad app permission admin-consent --id "${appId}"

    echo "Generating Azure AD access token to access Azure DevOps PAT API..."
    access_token=$(curl -sS -X POST -d 'grant_type=password&client_id='$appId'&username='$username'&password='$password'&scope=499b84ac-1321-427f-aa17-267ca6975798/.default' https://login.microsoftonline.com/$tenant/oauth2/v2.0/token | jq '.access_token')

    echo "Deploying resources..."
    ./Deploy -t $access_token -a oh.azureauth -s /source -i $subscription -o $rand
else
    echo "Skipping: Creating managed app ($devops) for generating Azure DevOps PAT token..."
    echo "Skipping: PAT token will be entered manually..."

    # Wait 60 seconds to ensure that Azure has successfully created service princpals
    sleep 60

    echo "Deploying resources..."
    ./Deploy -a oh.azureauth -s /source -i $subscription -o $rand
fi

echo 
echo "Deployment completed."
echo
