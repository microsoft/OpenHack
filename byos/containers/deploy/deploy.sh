#!/bin/bash

set -xeuo pipefail
IFS=$'\n\t'

declare region="westus"
declare teamRG="teamResources"
declare proctorRG="proctorResources"
declare suffix=""

declare createAdUsers=false

declare azureUserName=""
declare azurePassword=""
declare subscriptionId=""
declare tenantId=""

declare randstr=""

# Initialize parameters specified from command line
while getopts ":l:g:o:f:u:p:s:t:a:" arg; do
    case "${arg}" in
        l)
            region=${OPTARG}
        ;;
        g)
            teamRG=${OPTARG}
        ;;
        o)
            proctorRG=${OPTARG}
        ;;
        f)
            suffix=${OPTARG}
        ;;
        u)
            azureUserName=${OPTARG}
        ;;
        p)
            azurePassword=${OPTARG}
        ;;
        t)
            tenantId=${OPTARG}
        ;;
        s)
            subscriptionId=${OPTARG}
        ;;
        a)
            createAdUsers=true
        ;;
    esac
done
shift $((OPTIND-1))

if [[ -n "$suffix" ]]; then
	teamRG=$teamRG-$suffix
	proctorRG=$proctorRG-$suffix
fi

randomChar() {
    s=abcdefghijklmnopqrstuvxwyz
    p=$(( $RANDOM % 26))
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

randStr="$(randomChar;randomCharUpper;randomChar;randomNum;randomNum;randomNum;randomNum)"
registryName="$(echo "registry${randStr}" | tr '[:upper:]' '[:lower:]')"
sqlServerName="$(echo "sqlserver${randStr}" | tr '[:upper:]' '[:lower:]')"
sqlServerUsername="sqladmin${randStr}"
sqlServerPassword="$(randomChar;randomCharUpper;randomNum;randomChar;randomChar;randomNum;randomCharUpper;randomChar;randomNum)" 
sqlDBName="mydrivingDB"
simulatorName="simulator-app-$registryName"

echo "=========================================="
echo " VARIABLES"
echo "=========================================="
echo "region            = "${region}
echo "teamRG            = "${teamRG}
echo "proctorRG         = "${proctorRG}
echo "registryName      = "${registryName}
echo "sqlServerName     = "${sqlServerName}
echo "sqlServerUsername = "${sqlServerUsername}
echo "sqlDBName         = "${sqlDBName}

if [[ -n "${azureUserName}" && "${azurePassword}" ]]; then
    #login to azure using your credentials
    echo "Username: $azureUserName"

    if [[ -z "${tenantId}" ]]; then
        az login --username=$azureUserName --password=$azurePassword
    else
        az login --service-principal --username=$azureUserName --password=$azurePassword --tenant=$tenantId
    fi
fi

if [[ -n "${subscriptionId}" ]]; then
    # Setting sub:
    echo "Setting sub to ${subscriptionId}..."
    az account set -s $subscriptionId 
fi

echo "Registering preview features..."

az feature register --name APIServerSecurityPreview --namespace Microsoft.ContainerService
az feature register --name WindowsPreview --namespace Microsoft.ContainerService
az feature register --name PodSecurityPolicyPreview --namespace Microsoft.ContainerService
az feature register --name EnablePodIdentityPreview --namespace Microsoft.ContainerService
az feature register --name AKS-AzureKeyVaultSecretsProvider --namespace Microsoft.ContainerService

echo "Registering providers required..."
az provider register --namespace Microsoft.OperationsManagement
az provider register --namespace Microsoft.ContainerService

az group create -n $teamRG -l $region

# might be already created, but if not create here... 
az group create -n $proctorRG -l $region

# Create ACR
echo "Creating Azure Container Registry..."
ACR=$(az acr create -n $registryName -g $teamRG --sku Basic -o json)

if [ $? == 0 ];
then
    echo "Azure Container Registry" $registryName "created successfully..."
    # This step so that we don't need to do role assignement
    echo "Enable Registry for admin authentication"
    az acr update -n $registryName -g $teamRG --admin-enabled true

    echo "Building application images in ACR..."

    echo "dataload:1.0..."
    az acr build --registry $registryName -g $teamRG --no-wait --image dataload:1.0 dataload

    echo "insurance:1.0..."
    az acr build --registry $registryName -g $teamRG --no-wait --image insurance:1.0 insuranceapp-monitoring
    
    echo "wcfservice:1.0...X"
    az acr build --registry $registryName -g $teamRG --no-wait --image wcfservice:1.0 WinLegacyApp --platform Windows

    echo "tripviewer2:1.0..."
    az acr build --registry $registryName -g $teamRG --no-wait --image tripviewer2:1.0 tripviewer2

    # Replace hard coded localhost in simulator webpage
    # Create from template first so we don't overwrite
    cat ./ContainersSimulatorV2/views/index-template.html > ./ContainersSimulatorV2/views/index.html

    FQDN='simulator'${registryName}'.'${region}'.azurecontainer.io'
    sed -i -e 's localhost '${FQDN}' g' ContainersSimulatorV2/views/index.html

    echo "Building ContainerSimulatorV2 components..."
    echo "simulator:1.0..."
    az acr build --registry $registryName -g $teamRG --image simulator:1.0 ContainersSimulatorV2 -f ContainersSimulatorV2/Dockerfile --no-wait

    echo "prometheus-sim:1.0..."
    az acr build --registry $registryName -g $teamRG --image prometheus-sim:1.0 ContainersSimulatorV2 -f ContainersSimulatorV2/Dockerfile.prometheus --no-wait

    echo "grafana-sim:1.0..."
    az acr build --registry $registryName -g $teamRG --image grafana-sim:1.0 ContainersSimulatorV2 -f ContainersSimulatorV2/Dockerfile.grafana --no-wait 
fi

# Create VNET
echo "Creating VNET with VM..."
az network vnet create -g $teamRG -n vnet --address-prefix 10.2.0.0/22 --subnet-name vm-subnet --subnet-prefix 10.2.0.0/24

if [ $? == 0 ];
then
    echo "Azure VNET created successfully."
fi

# Create VM
az vm create -n internal-vm -g $teamRG --admin-username azureuser --generate-ssh-keys --public-ip-address "" --image UbuntuLTS --vnet-name vnet --subnet vm-subnet

if [ $? == 0 ];
then
    echo "VM created successfully in subnet"
fi

# Create Azure SQL Server instance
echo "Creating Azure SQL Server instance..."
az sql server create -g $teamRG -n $sqlServerName -u $sqlServerUsername -p $sqlServerPassword

if [ $? == 0 ];
then
    echo "SQL Server created successfully."
    echo "Adding firewall rule to SQL server..."
    az sql server firewall-rule create -g $teamRG --server $sqlServerName -n "Allow Access To Azure Services" --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0
    
    if [ $? == 0 ];
    then
        echo "Firewall rule added successfully to SQL server."
    else
        echo "Failed to add firewall rule to SQL server."
    fi

    # Create Azure SQL DB
    echo "Creating Azure SQL DB..."
    az sql db create -g $teamRG -s $sqlServerName -n $sqlDBName

else
    echo "Failed to create SQL Server."
fi

# Check on builds
echo "Checking on builds..."

END=$(( $(date +%s) + 900 ))
while true
do
    status=$(az acr task list-runs -r $registryName -g $teamRG --query [].status -o tsv | tr ' ' '\n'| sort -u)
    if [[ $status =~ "Failed" ]];
    then
        echo "One or more ACR builds failed."
        failed=$(az acr task list-runs -r $registryName -g $teamRG --run-status Failed --query [].name -o tsv | tr ' ' '\n' )
        for i in "${failed[@]}"
        do
            echo "Logs for failed build $i:"
            echo "$(az acr task logs -r $registryName -g $teamRG --run-id $i)"
        done
        exit 1
    fi
    if [[ $status == "Succeeded" ]];
    then
        echo "All ACR builds succeeded."
        break
    fi

    # Timeout if no success after 15 minutes
    if [[ $(date +%s) -gt $END ]];
    then
        break
    fi
    sleep 1m
done

registryPassword="$(az acr credential show -n $registryName -g $teamRG --query 'passwords[0].value' --output tsv)"
registryLoginServer="$registryName.azurecr.io"

echo "Loading data in SQL database..."
az container create -g $proctorRG --name dataload --image $registryLoginServer/dataload:1.0 --registry-login-server $registryLoginServer --registry-username $registryName --registry-password $registryPassword \
    --secure-environment-variables SQLFQDN=$sqlServerName.database.windows.net SQLUSER=$sqlServerUsername SQLPASS=$sqlServerPassword SQLDB=$sqlDBName

logs=$(az container logs -g $proctorRG --name dataload)
if [[ logs =~ "BCP copy in failed" ]]; then
    echo "Failed to load data into database."
else
    echo "Successfully loaded data into database."
fi

echo "Creating simulator..."
./ContainersSimulatorV2/deploy-aci.sh $region $teamRG $simulatorName $registryLoginServer 1.0 $registryName $registryPassword
simulatorfqdn=$(az container show -n $simulatorName -g $teamRG --query 'ipAddress.fqdn' --out tsv)

if [ $? == 0 ];
then
    echo "Simulator v2 deployed to ACI successfully at $simulatorfqdn"
else
    echo "Failed to deploy simulator v2 to ACI."
fi

if "$createAdUsers"; then
    if [[ -z "$azureUserName" ]]; then
        azureUserName=$(az account show --query user.name -o tsv)
    fi
    domain=$(cut -d "@" -f 2 <<< $azureUserName)

    webdevpassword="$(randomChar;randomCharUpper;randomNum;randomChar;randomChar;randomNum;randomCharUpper;randomChar;randomNum)" 
    apidevpassword="$(randomChar;randomCharUpper;randomNum;randomChar;randomChar;randomNum;randomCharUpper;randomChar;randomNum)" 

    echo "Creating webdev and apidev users..."
    az ad user create --display-name api-dev --password $apidevpassword --user-principal-name apidev@$domain

    az ad user create --display-name web-dev --password $webdevpassword --user-principal-name webdev@$domain
fi

echo "ACR Login Server: $registryLoginServer"
echo "ACR Username: $registryName"
echo "ACR Password: $registryPassword"
echo "SQL Server: $sqlServerName"
echo "SQL Server Username: $sqlServerUsername"
echo "SQL Server Password: $sqlServerPassword"
echo "Simulator url: $simulatorfqdn"

if "${createAdUsers}"; then
    echo "api-dev password: $apidevpassword"
    echo "web-dev password: $webdevpassword"
fi
