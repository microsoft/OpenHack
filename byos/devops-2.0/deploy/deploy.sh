#!/bin/bash

# set -euo pipefail
IFS=$'\n\t'

declare AZURE_USERNAME=""
declare AZURE_PASSWORD=""
declare RESOURCEGROUPLOCATION=""
declare RGSUFFIX=""
declare ACRNAME=""
declare -r GITOHTEAMURI="https://github.com/Azure-Samples/openhack-devops-team.git"
declare -r GITOHTEAMDIRNAME="openhack-devops-team"
declare -r GITOHTEAMBRANCH="origin/master"
declare -r GITOHPROCTORURI="https://github.com/Azure-Samples/openhack-devops-proctor.git"
declare -r GITOHPROCTORDIRNAME="openhack-devops-proctor"
declare -r GITOHPROCTORBRANCH="origin/master"
declare -r SQL_USERNAME="demousersa"
declare -r SQL_PASSWORD="demo@pass123"
declare -r DATABASENAME="mydrivingDB"
declare -r JENKINS_USERNAME="demouser"
declare -r JENKINS_PASSWORD="demo@pass123"
declare -r BINGMAPSKEY="Ar6iuHZYgX1BrfJs6SRJaXWbpU_HKdoe7G-OO9b2kl3rWvcawYx235GGx5FPM76O"
declare -r SQLFWRULENAME="SetupAccountFWIP"
declare -r BASEIMAGETAG="changeme"

declare -r USAGESTRING="Usage: deploy.sh -l <RESOURCEGROUPLOCATION> [-s <RGSUFFIX> -u <AZURE_USERNAME> -p <AZURE_PASSWORD>]"

# Verify the type of input and number of values
# Display an error message if the input is not correct
# Exit the shell script with a status of 1 using exit 1 command.
if [ $# -eq 0 ]; then
    echo $USAGESTRING 2>&1; exit 1; 
fi

# Initialize parameters specified from command line
while getopts ":l:s:u:p:" arg; do
    case "${arg}" in
        l) # Process -l (Location)
            RESOURCEGROUPLOCATION=${OPTARG}
        ;;
        s) # Process -s (Suffix)
            RGSUFFIX=${OPTARG}
        ;;
        u) # Process -u (Username)
            AZURE_USERNAME=${OPTARG}
        ;;
        p) # Process -p (Password)
            AZURE_PASSWORD=${OPTARG} 
        ;;
        \?)
            echo "Invalid options found: -$OPTARG."
            echo $USAGESTRING 2>&1; exit 1; 
        ;;
    esac
done
shift $((OPTIND-1))

# Check for programs
if ! [ -x "$(command -v az)" ]; then
  echo "Error: az is not installed." 2>&1
  exit 1
elif ! [ -x "$(command -v sqlcmd)" ]; then
  echo "Error: sqlcmd is not installed." 2>&1
  exit 1
elif ! [ -x "$(command -v bcp)" ]; then
  echo "Error: bcp is not installed." 2>&1
  exit 1
elif ! [ -x "$(command -v dig)" ]; then
  echo "Error: dig is not installed." 2>&1
  exit 1 
elif ! [ -x "$(command -v git)" ]; then
  echo "Error: git is not installed." 2>&1
  exit 1 
fi

randomChar() {
    s=abcdefghijklmnopqrstuvxwyz0123456789
    p=$(( $RANDOM % 36))
    echo -n ${s:$p:1}
}

randomNum() {
    echo -n $(( $RANDOM % 10 ))
}

randomCharUpper() {
    s=ABCDEFGHIJKLMNOPQRSTUVWXYZ
    p=$(( $RANDOM % 26))
    echo -n ${s:$p:1}
}

submitACRBuild() {
    local REPOPRESENT=""
    echo "Repository name: ${1}"
    echo "Image tag: ${2}"
    for (( c=1; c<=5; c++ ))
    do  
        REPOPRESENT=$(az acr repository list --name $ACRNAME --query "[?contains(@,'${1}')]" -o tsv)
        echo "REPOPRESENT: $REPOPRESENT"
        if [ -z $REPOPRESENT ]; then
            echo "Repository $1 not found. Creating repository (run $c)"
            az acr build --image "devopsoh/${1}:${2}" --registry $ACRNAME --build-arg build_version=$2 --file Dockerfile .
            sleep 10
        else
            echo "Repository $1 found!"
            break
        fi
    done
}

if [ ${#RGSUFFIX} -eq 0 ]; then
    RGSUFFIX="$(randomChar;randomChar;randomChar;randomNum;randomChar;randomChar;randomChar;randomNum;)"
fi

echo "Resource random suffix: "$RGSUFFIX

RGNAME="openhack${RGSUFFIX}rg"

# Accommodate Cloud Sandbox startup
if [ ${#AZURE_USERNAME} -gt 0 ] && [ ${#AZURE_PASSWORD} -gt 0 ]; then
    echo "Authenticating to Azure with username and password..."
    az login --username $AZURE_USERNAME --password $AZURE_PASSWORD
fi

RGEXISTS=$(az group show --name $RGNAME --query name)
if [ ${#RGEXISTS} -eq 0 ]; then
    echo "Resource group $RGNAME was not found. Creating resource group..."
    echo "Creating resource group $RGNAME in location $RESOURCEGROUPLOCATION"

    az group create --name $RGNAME --location $RESOURCEGROUPLOCATION
else
    echo "Using existing resource group $RGNAME."
fi

echo "Checking basedeployment to $RGNAME..."
RGDEPLOYMENTSTATE=$(az deployment group show --resource-group $RGNAME --name basedeployment --query properties.provisioningState -o tsv)
if [ ${#RGDEPLOYMENTSTATE} -eq 0 ]; then
    echo "Starting deployment to $RGNAME..."
    az deployment group create --name "basedeployment" --resource-group $RGNAME --template-file ./azuredeploy.json --parameters resourceRandomSuffix=$RGSUFFIX
else
    echo "basedeployment already completed."
fi

echo "Retrieving ACR information..."
ACRNAME=$(az acr list --resource-group $RGNAME --query [].name -o tsv)
echo "Found ACR at $ACRNAME."

if [ ${#ACRNAME} -eq 0 ]; then
    echo "Azure Container Registry name not found." 2>&1; exit 1;
fi

APPSVCPLANNAME="openhack${RGSUFFIX}plan"
echo "Setting App Service Plan name to $APPSVCPLANNAME..."
SQLFQDN=$(az sql server list --resource-group $RGNAME --query [].fullyQualifiedDomainName -o tsv)
echo "Setting SQL fqdn to $SQLFQDN..."

if [ ${#SQLFQDN} -eq 0 ]; then
    echo "Azure SQL was not found." 2>&1; exit 1;
fi

echo "Setting DB firewall rule for local configuration host..."
MYCURRENTIP="$(dig +short myip.opendns.com @resolver1.opendns.com)"
echo "Adding firewall rule for ${MYCURRENTIP} to openhack${RGSUFFIX}sql..."
az sql server firewall-rule create \
    --resource-group $RGNAME \
    --server "openhack${RGSUFFIX}sql" \
    --name $SQLFWRULENAME \
    --start-ip-address $MYCURRENTIP \
    --end-ip-address $MYCURRENTIP

# Make a temporary path for cloning from the existing git repos
TEMPDIRNAME="temp$RGSUFFIX"

echo "Creating temporary directory $TEMPDIRNAME..."
mkdir $TEMPDIRNAME

FULLTEMPDIRPATH="$PWD/$TEMPDIRNAME"
FULLCURRENTPATH=$PWD

echo "Full tempoary directory is $FULLTEMPDIRPATH..."

cd $TEMPDIRNAME

echo "Cloning $GITOHTEAMURI"
git clone $GITOHTEAMURI

GITOHTEAMDIRPATH="$FULLTEMPDIRPATH/$GITOHTEAMDIRNAME"

cd $GITOHTEAMDIRPATH
echo "Switching to branch $GITOHTEAMBRANCH..."
git checkout $GITOHTEAMBRANCH

cd $FULLTEMPDIRPATH

echo "Cloning $GITOHPROCTORURI"
git clone $GITOHPROCTORURI

GITOHPROCTORDIRPATH="$FULLTEMPDIRPATH/$GITOHPROCTORDIRNAME"

cd $GITOHPROCTORDIRPATH
echo "Switching to branch $GITOHPROCTORBRANCH..."
git checkout $GITOHPROCTORBRANCH

# BUILD POI
echo "Building API-POI image..."
echo "Changing directory to $GITOHTEAMDIRPATH/apis/poi/web..."
cd "$GITOHTEAMDIRPATH/apis/poi/web"

submitACRBuild "api-poi" $BASEIMAGETAG

# BUILD TRIPS
echo "Building API-TRIPS image..."
echo "Changing directory to $GITOHTEAMDIRPATH/apis/trips..."
cd "$GITOHTEAMDIRPATH/apis/trips"

submitACRBuild "api-trips" $BASEIMAGETAG

# BUILD USER-JAVA
echo "Building API-USER-JAVA image..."
echo "Changing directory to $GITOHTEAMDIRPATH/apis/user-java..."
cd "$GITOHTEAMDIRPATH/apis/user-java"

submitACRBuild "api-user-java" $BASEIMAGETAG

# BUILD USERPROFILE
echo "Building API-USERPROFILE image..."
echo "Changing directory to $GITOHTEAMDIRPATH/apis/userprofile..."
cd "$GITOHTEAMDIRPATH/apis/userprofile"

submitACRBuild "api-userprofile" $BASEIMAGETAG

# BUILD TripViewer
echo "Building Tripviewer image..."
echo "Changing directory to $GITOHPROCTORDIRPATH/tripviewer..."
cd "$GITOHPROCTORDIRPATH/tripviewer"

submitACRBuild "tripviewer" "latest"

# BUILD Simulator
echo "Building Simulator image..."
echo "Changing directory to $GITOHPROCTORDIRPATH/simulator..."
cd "$GITOHPROCTORDIRPATH/simulator"

submitACRBuild "simulator" "latest"

# Final sanity check for repositories being present
REPOSITORYCOUNT=$(az acr repository list --name $ACRNAME --query "[length(@)]" -o tsv)
if [ $REPOSITORYCOUNT -eq 6 ]; then 
    echo "All repositories built successfully!"
else 
    echo "All Azure Container Registry repositories not found." 2>&1; exit 1;
fi

echo "Creating Key Vault..."
az keyvault create --name "openhack${RGSUFFIX}kv" --resource-group $RGNAME --location $RESOURCEGROUPLOCATION
az keyvault secret set --vault-name "openhack${RGSUFFIX}kv" --name "SQLUSER" --value $SQL_USERNAME
az keyvault secret set --vault-name "openhack${RGSUFFIX}kv" --name "SQLPASSWORD" --value $SQL_PASSWORD
az keyvault secret set --vault-name "openhack${RGSUFFIX}kv" --name "SQLSERVER" --value $SQLFQDN
az keyvault secret set --vault-name "openhack${RGSUFFIX}kv" --name "SQLDBNAME" --value $DATABASENAME

IDKVSQLUSER=$(az keyvault secret show --vault-name "openhack${RGSUFFIX}kv" --name "SQLUSER" --query id -o tsv)
KVSQLUSER="@Microsoft.KeyVault(SecretUri=${IDKVSQLUSER})"
IDKVSQLPASSWORD=$(az keyvault secret show --vault-name "openhack${RGSUFFIX}kv" --name "SQLPASSWORD" --query id -o tsv)
KVSQLPASSWORD="@Microsoft.KeyVault(SecretUri=${IDKVSQLPASSWORD})"
IDKVSQLSERVER=$(az keyvault secret show --vault-name "openhack${RGSUFFIX}kv" --name "SQLSERVER" --query id -o tsv)
KVSQLSERVER="@Microsoft.KeyVault(SecretUri=${IDKVSQLSERVER})"
IDKVSQLDBNAME=$(az keyvault secret show --vault-name "openhack${RGSUFFIX}kv" --name "SQLDBNAME" --query id -o tsv)
KVSQLDBNAME="@Microsoft.KeyVault(SecretUri=${IDKVSQLDBNAME})"

echo "Creating Tripviewer web app..."
az webapp create --resource-group $RGNAME --plan $APPSVCPLANNAME --name "openhack${RGSUFFIX}tripviewer" --deployment-container-image-name "${ACRNAME}.azurecr.io/devopsoh/tripviewer:latest"
echo "Assigning managed identity to openhack${RGSUFFIX}tripviewer..."
az webapp identity assign --resource-group $RGNAME --name "openhack${RGSUFFIX}tripviewer"
IDTRIPVIEWER=$(az webapp identity show --resource-group $RGNAME --name "openhack${RGSUFFIX}tripviewer" --query principalId -o tsv)
echo "Setting Key Vault permissions..."
az keyvault set-policy --name "openhack${RGSUFFIX}kv" --object-id $IDTRIPVIEWER --secret-permissions get
echo "Setting Tripviewer app settings..."
az webapp config appsettings set -g $RGNAME -n "openhack${RGSUFFIX}tripviewer" --settings BING_MAPS_KEY=$BINGMAPSKEY
az webapp config appsettings set -g $RGNAME -n "openhack${RGSUFFIX}tripviewer" --settings USER_ROOT_URL=https://openhack${RGSUFFIX}userprofile.azurewebsites.net
az webapp config appsettings set -g $RGNAME -n "openhack${RGSUFFIX}tripviewer" --settings USER_JAVA_ROOT_URL=https://openhack${RGSUFFIX}userjava.azurewebsites.net
az webapp config appsettings set -g $RGNAME -n "openhack${RGSUFFIX}tripviewer" --settings TRIPS_ROOT_URL=https://openhack${RGSUFFIX}trips.azurewebsites.net
az webapp config appsettings set -g $RGNAME -n "openhack${RGSUFFIX}tripviewer" --settings POI_ROOT_URL=https://openhack${RGSUFFIX}poi.azurewebsites.net

echo "Creating API-POI web app..."
az webapp create --resource-group $RGNAME --plan $APPSVCPLANNAME --name "openhack${RGSUFFIX}poi" --deployment-container-image-name "${ACRNAME}.azurecr.io/devopsoh/api-poi:${BASEIMAGETAG}"
echo "Assigning managed identity to openhack${RGSUFFIX}poi..."
az webapp identity assign --resource-group $RGNAME --name "openhack${RGSUFFIX}poi"
IDPOI=$(az webapp identity show --resource-group $RGNAME --name "openhack${RGSUFFIX}poi" --query principalId -o tsv)
echo "Setting Key Vault permissions..."
az keyvault set-policy --name "openhack${RGSUFFIX}kv" --object-id $IDPOI --secret-permissions get
echo "Setting POI app settings..."
az webapp config appsettings set -g $RGNAME -n "openhack${RGSUFFIX}poi" --settings WEBSITES_PORT=8080
az webapp config appsettings set -g $RGNAME -n "openhack${RGSUFFIX}poi" --settings CONTAINER_AVAILABILITY_CHECK_MODE=Off
az webapp config appsettings set -g $RGNAME -n "openhack${RGSUFFIX}poi" --settings SQL_USER=$KVSQLUSER
az webapp config appsettings set -g $RGNAME -n "openhack${RGSUFFIX}poi" --settings SQL_PASSWORD=$KVSQLPASSWORD
az webapp config appsettings set -g $RGNAME -n "openhack${RGSUFFIX}poi" --settings SQL_SERVER=$KVSQLSERVER
az webapp config appsettings set -g $RGNAME -n "openhack${RGSUFFIX}poi" --settings SQL_DBNAME=$KVSQLDBNAME

echo "Creating API-POI web app staging slot"
az webapp deployment slot create --name "openhack${RGSUFFIX}poi" --resource-group $RGNAME --slot staging --configuration-source "openhack${RGSUFFIX}poi"
echo "Assigning managed identity to openhack${RGSUFFIX}poi-staging..."
az webapp identity assign --resource-group $RGNAME --name "openhack${RGSUFFIX}poi" --slot staging
IDPOISTAGING=$(az webapp identity show --resource-group $RGNAME --name "openhack${RGSUFFIX}poi" --slot staging --query principalId -o tsv)
echo "Setting Key Vault permissions..."
az keyvault set-policy --name "openhack${RGSUFFIX}kv" --object-id $IDPOISTAGING --secret-permissions get

echo "Creating API-TRIPS web app..."
az webapp create --resource-group $RGNAME --plan $APPSVCPLANNAME --name "openhack${RGSUFFIX}trips" --deployment-container-image-name "${ACRNAME}.azurecr.io/devopsoh/api-trips:${BASEIMAGETAG}"
echo "Assigning managed identity to openhack${RGSUFFIX}trips..."
az webapp identity assign --resource-group $RGNAME --name "openhack${RGSUFFIX}trips"
IDTRIPS=$(az webapp identity show --resource-group $RGNAME --name "openhack${RGSUFFIX}trips" --query principalId -o tsv)
echo "Setting Key Vault permissions..."
az keyvault set-policy --name "openhack${RGSUFFIX}kv" --object-id $IDTRIPS --secret-permissions get
echo "Setting TRIPS app settings..."
az webapp config appsettings set -g $RGNAME -n "openhack${RGSUFFIX}trips" --settings SQL_USER=$KVSQLUSER
az webapp config appsettings set -g $RGNAME -n "openhack${RGSUFFIX}trips" --settings SQL_PASSWORD=$KVSQLPASSWORD
az webapp config appsettings set -g $RGNAME -n "openhack${RGSUFFIX}trips" --settings SQL_SERVER=$KVSQLSERVER
az webapp config appsettings set -g $RGNAME -n "openhack${RGSUFFIX}trips" --settings SQL_DBNAME=$KVSQLDBNAME

echo "Creating API-TRIPS web app staging slot"
az webapp deployment slot create --name "openhack${RGSUFFIX}trips" --resource-group $RGNAME --slot staging --configuration-source "openhack${RGSUFFIX}trips"
echo "Assigning managed identity to openhack${RGSUFFIX}trips-staging..."
az webapp identity assign --resource-group $RGNAME --name "openhack${RGSUFFIX}trips" --slot staging
IDTRIPSSTAGING=$(az webapp identity show --resource-group $RGNAME --name "openhack${RGSUFFIX}trips" --slot staging --query principalId -o tsv)
echo "Setting Key Vault permissions..."
az keyvault set-policy --name "openhack${RGSUFFIX}kv" --object-id $IDTRIPSSTAGING --secret-permissions get

echo "Creating API-USER-JAVA web app..."
az webapp create --resource-group $RGNAME --plan $APPSVCPLANNAME --name "openhack${RGSUFFIX}userjava" --deployment-container-image-name "${ACRNAME}.azurecr.io/devopsoh/api-user-java:${BASEIMAGETAG}"
echo "Assigning managed identity to openhack${RGSUFFIX}userjava..."
az webapp identity assign --resource-group $RGNAME --name "openhack${RGSUFFIX}userjava"
IDUSERJAVA=$(az webapp identity show --resource-group $RGNAME --name "openhack${RGSUFFIX}userjava" --query principalId -o tsv)
echo "Setting Key Vault permissions..."
az keyvault set-policy --name "openhack${RGSUFFIX}kv" --object-id $IDUSERJAVA --secret-permissions get
echo "Setting USERJAVA app settings..."
az webapp identity assign --resource-group $RGNAME --name "openhack${RGSUFFIX}userjava"
az webapp config appsettings set -g $RGNAME -n "openhack${RGSUFFIX}userjava" --settings SQL_USER=$KVSQLUSER
az webapp config appsettings set -g $RGNAME -n "openhack${RGSUFFIX}userjava" --settings SQL_PASSWORD=$KVSQLPASSWORD
az webapp config appsettings set -g $RGNAME -n "openhack${RGSUFFIX}userjava" --settings SQL_SERVER=$KVSQLSERVER
az webapp config appsettings set -g $RGNAME -n "openhack${RGSUFFIX}userjava" --settings SQL_DBNAME=$KVSQLDBNAME

echo "Creating API-USER-JAVA web app staging slot"
az webapp deployment slot create --name "openhack${RGSUFFIX}userjava" --resource-group $RGNAME --slot staging --configuration-source "openhack${RGSUFFIX}userjava"
echo "Assigning managed identity to openhack${RGSUFFIX}userjava-staging..."
az webapp identity assign --resource-group $RGNAME --name "openhack${RGSUFFIX}userjava" --slot staging
IDUSERJAVASTAGING=$(az webapp identity show --resource-group $RGNAME --name "openhack${RGSUFFIX}userjava" --slot staging --query principalId -o tsv)
echo "Setting Key Vault permissions..."
az keyvault set-policy --name "openhack${RGSUFFIX}kv" --object-id $IDUSERJAVASTAGING --secret-permissions get

echo "Creating API-USERPROFILE web app..."
az webapp create --resource-group $RGNAME --plan $APPSVCPLANNAME --name "openhack${RGSUFFIX}userprofile" --deployment-container-image-name "${ACRNAME}.azurecr.io/devopsoh/api-userprofile:${BASEIMAGETAG}"
echo "Assigning managed identity to openhack${RGSUFFIX}userprofile..."
az webapp identity assign --resource-group $RGNAME --name "openhack${RGSUFFIX}userprofile"
IDUSERPROFILE=$(az webapp identity show --resource-group $RGNAME --name "openhack${RGSUFFIX}userprofile" --query principalId -o tsv)
echo "Setting Key Vault permissions..."
az keyvault set-policy --name "openhack${RGSUFFIX}kv" --object-id $IDUSERPROFILE --secret-permissions get
echo "Setting USERPROFILE app settings..."
az webapp config appsettings set -g $RGNAME -n "openhack${RGSUFFIX}userprofile" --settings SQL_USER=$KVSQLUSER
az webapp config appsettings set -g $RGNAME -n "openhack${RGSUFFIX}userprofile" --settings SQL_PASSWORD=$KVSQLPASSWORD
az webapp config appsettings set -g $RGNAME -n "openhack${RGSUFFIX}userprofile" --settings SQL_SERVER=$KVSQLSERVER
az webapp config appsettings set -g $RGNAME -n "openhack${RGSUFFIX}userprofile" --settings SQL_DBNAME=$KVSQLDBNAME

echo "Creating API-USERPROFILE web app staging slot"
az webapp deployment slot create --name "openhack${RGSUFFIX}userprofile" --resource-group $RGNAME --slot staging --configuration-source "openhack${RGSUFFIX}userprofile"
echo "Assigning managed identity to openhack${RGSUFFIX}userprofile-staging..."
az webapp identity assign --resource-group $RGNAME --name "openhack${RGSUFFIX}userprofile" --slot staging
IDUSERPROFILESTAGING=$(az webapp identity show --resource-group $RGNAME --name "openhack${RGSUFFIX}userprofile" --slot staging --query principalId -o tsv)
echo "Setting Key Vault permissions..."
az keyvault set-policy --name "openhack${RGSUFFIX}kv" --object-id $IDUSERPROFILESTAGING --secret-permissions get

echo "Populating SQL database..."
echo "Changing directory to $GITOHPROCTORDIRPATH/provision-team..."
cd "$GITOHPROCTORDIRPATH/provision-team"
echo "Creating database schema..."
sqlcmd -U $SQL_USERNAME -P $SQL_PASSWORD -S $SQLFQDN -d $DATABASENAME -i ./MYDrivingDB.sql -e
echo "Populating database with seed data..."
bash ./sql_data_init.sh -s $SQLFQDN -u $SQL_USERNAME -p $SQL_PASSWORD -d $DATABASENAME 

echo "Removing configuration host FW rule on openhack${RGSUFFIX}sql..."
az sql server firewall-rule delete \
    --resource-group $RGNAME \
    --server "openhack${RGSUFFIX}sql" \
    --name $SQLFWRULENAME

echo "Deploying simulator container..."
az container create \
    --name "openhack${RGSUFFIX}simulator" \
    --resource-group $RGNAME \
    --image "${ACRNAME}.azurecr.io/devopsoh/simulator:latest" \
    --registry-login-server "${ACRNAME}.azurecr.io" \
    --registry-username $(az acr credential show --name $ACRNAME --query username -o tsv) \
    --registry-password $(az acr credential show --name $ACRNAME --query passwords[0].value -o tsv) \
    --dns-name-label "openhack${RGSUFFIX}simulator" \
    --environment-variables "SQL_USER"="${SQL_USERNAME}" "SQL_PASSWORD"="${SQL_PASSWORD}" "SQL_SERVER"="${SQLFQDN}" "SQL_DBNAME"="${DATABASENAME}" "TEAM_NAME"="openhack${RGSUFFIX}" "USER_ROOT_URL"="https://openhack${RGSUFFIX}userprofile.azurewebsites.net" "TRIPS_ROOT_URL"="https://openhack${RGSUFFIX}trips.azurewebsites.net" "POI_ROOT_URL"="https://openhack${RGSUFFIX}poi.azurewebsites.net" \
    --query ipAddress.fqdn

# BUILD JENKINS
echo "Building JENKINS image..."
echo "Changing directory to $GITOHPROCTORDIRPATH/provision-team/jenkins..."
cd "$GITOHPROCTORDIRPATH/provision-team/jenkins"
az acr build --image devopsoh/jenkins:latest --registry $ACRNAME --file Dockerfile --build-arg JENKINS_USERNAME=${JENKINS_USERNAME} --build-arg JENKINS_PASSWORD=${JENKINS_PASSWORD} .

# DEPLOY JENKINS TO ACI
echo "Deploying jenkins container..."
az container create \
    --name "openhack${RGSUFFIX}jenkins" \
    --resource-group $RGNAME \
    --image "${ACRNAME}.azurecr.io/devopsoh/jenkins:latest" \
    --registry-login-server "${ACRNAME}.azurecr.io" \
    --registry-username $(az acr credential show --name $ACRNAME --query username -o tsv) \
    --registry-password $(az acr credential show --name $ACRNAME --query passwords[0].value -o tsv) \
    --dns-name-label "openhack${RGSUFFIX}jenkins" \
    --port 8080 \
    --query ipAddress.fqdn

cd $FULLCURRENTPATH

echo "Removing temporary files..."
rm -rf $FULLTEMPDIRPATH
