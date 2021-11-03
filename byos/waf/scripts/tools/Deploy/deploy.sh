#!/bin/sh

deviceLogin=false
verbose=false

while getopts u:p:s:t:dvm:a: flag
do
    case "${flag}" in
        u) username=${OPTARG};;
        p) password=${OPTARG};;
        s) subscription=${OPTARG};;
        t) tenant=${OPTARG};;
        d) deviceLogin=true;;
        v) verbose=true;;
        m) manualPat=${OPTARG};;
        a) azureDevOps=${OPTARG};;
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

# Wait 60 seconds to ensure that Azure has successfully created service princpals
sleep 60

echo "Deploying resources..."
./Deploy -a oh.azureauth -s /source -i $subscription -o $rand -t $manualPat -d $azureDevOps

echo 
echo "Deployment completed."
echo