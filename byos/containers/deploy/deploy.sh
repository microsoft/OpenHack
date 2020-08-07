#!/bin/bash
# set -xeuo pipefail
IFS=$'\n\t'

declare region="westus"
declare resourceGroupName="teamResources"
declare suffix=""
declare proctorRG="proctorResources"
declare randstr=""


# Initialize parameters specified from command line
while getopts ":c:s:l:i:q:r:u:p:t:g:o:" arg; do
    case "${arg}" in
        r)
            region=${OPTARG}
        ;;
        t)
            resourceGroupName=${OPTARG}
        ;;
        s)
            suffix=${OPTARG}
        ;;
    esac
done
shift $((OPTIND-1))

declare teamRG=$resourceGroupName

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
dataLoadImage="openhack/data-load:v1"
webdevpassword="$(randomChar;randomCharUpper;randomNum;randomChar;randomChar;randomNum;randomCharUpper;randomChar;randomNum)" 
apidevpassword="$(randomChar;randomCharUpper;randomNum;randomChar;randomChar;randomNum;randomCharUpper;randomChar;randomNum)" 

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

echo "Registering preview features..."

az feature register --name APIServerSecurityPreview --namespace Microsoft.ContainerService
az feature register --name WindowsPreview --namespace Microsoft.ContainerService
az feature register --name PodSecurityPolicyPreview --namespace Microsoft.ContainerService

echo "Registering providers required..."
az provider register --namespace Microsoft.OperationsManagement

az group create -n $teamRG -l $region

# might be already created, but if not create here... 
az group create -n $proctorRG -l $region

# Create ACR
echo "Creating Azure Container Registry..."
ACR=$(az acr create -n $registryName -g $teamRG -l $region --sku Basic -o json)

if [ $? == 0 ];
then
    echo "Azure Container Registry" $registryName "created successfully..."
    # This step so that we don't need to do role assignement
    echo "Enable Registry for admin authentication"
    az acr update -n $registryName --admin-enabled true

   
    echo "Deploying application images..." 
    echo "insurance:1.0..."
    az acr build --registry $registryName --no-wait --image insurance:1.0 insuranceapp-monitoring
    
    echo "wcfservice:1.0...X"
    az acr build --registry $registryName --image wcfservice:1.0 WinLegacyApp --platform Windows --no-wait

    echo "tripviewer2:1.0..."
    az acr build --registry $registryName --no-wait --image tripviewer2:1.0 tripviewer2

    # Replace hard coded localhost in simulator webpage
    FQDN='simulator'${registryName}'.'${region}'.azurecontainer.io'
    sed -i -e 's localhost '${FQDN}' g' ContainersSimulatorV2/views/index.html

    echo "Deploying ContainerSimulatorV2 artifacts..."
    echo "simulator:1.0..."
    az acr build --registry $registryName --no-wait --image simulator:1.0  ContainersSimulatorV2

    echo "prometheus-sim:1.0..."
    az acr build --registry $registryName --no-wait --image prometheus-sim:1.0 ContainersSimulatorV2/prometheus

    echo "grafana-sim:1.0..."
    az acr build --registry $registryName --no-wait --image grafana-sim:1.0 ContainersSimulatorV2/grafana   
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
az sql server create -l $region -g $teamRG -n $sqlServerName -u $sqlServerUsername -p $sqlServerPassword

if [ $? == 0 ];
then
    echo "SQL Server created successfully."
    echo "Adding firewall rule to SQL server..."
    az sql server firewall-rule create --resource-group $teamRG --server $sqlServerName -n "Allow Access To Azure Services" --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0
    
    if [ $? == 0 ];
    then
        echo "Firewall rule added successfully to SQL server."
    else
        echo "Failed to add firewall rule to SQL server."
    fi

    # Create Azure SQL DB
    echo "Creating Azure SQL DB..."
    az sql db create -g $teamRG -s $sqlServerName -n $sqlDBName

    echo "SQL database created successfully."
    az container create -g $proctorRG --name dataload --image $dataLoadImage --secure-environment-variables SQLFQDN=$sqlServerName.database.windows.net SQLUSER=$sqlServerUsername SQLPASS=$sqlServerPassword SQLDB=$sqlDBName
else
    echo "Failed to create SQL Server."
fi

# Check on builds
echo "Checking on builds..."

END=$(( $(date +%s) + 900 ))
while true
do
    status=$(az acr task list-runs -r $registryName --query [].status -o tsv | tr ' ' '\n'| sort -u)
    if [[ $status =~ "Failed" ]];
    then
        echo "One or more ACR builds failed."
        failed=$(az acr task list-runs -r $registryName --run-status Failed --query [].name -o tsv | tr ' ' '\n' )
        for i in "${failed[@]}"
        do
            echo "Logs for failed build $i:"
            echo "$(az acr task logs -r $registryName -n $i)"
        done
        exit 1
    fi
    if [[ $status == "Succeeded" ]];
    then
        echo "All ACR builds succeeded."
        break
    fi

    # Timeout if no success after 15 minutes
    if [[ $(date +%s) -gt $END ]]; then
        break
    fi
    sleep 1m
done

echo "Creating simulator..."
# Create simulator
if [ $? == 0 ];
then
    ACR_PASS="$(az acr credential show -n $registryName --query 'passwords[0].value' --output tsv)"
	
	sed -i -e 's/SIM_NAME/'${simulatorName}'/g' ./aci-deploy.yaml
	sed -i -e 's/REGISTRY/'${registryName}'.azurecr.io/g' ./aci-deploy.yaml
	sed -i -e 's/TAG/1.0/g' ./aci-deploy.yaml
	sed -i -e 's/ACR_NAME/'${registryName}'/g' ./aci-deploy.yaml
	sed -i -e 's ACR_PASS '${ACR_PASS}' g' ./aci-deploy.yaml

	az container create --resource-group $teamRG --location $region --file --file ./aci-deploy.yaml

    simulatorfqdn=$(az container show -n $simulatorName -g $teamRG --query 'ipAddress.fqdn' --out tsv)
	
    if [ $? == 0 ];
    then
        echo "Simulator v2 deployed to ACI successfully at" + $simulatorfqdn
    else
        echo "Failed to deploy simulator v2 to ACI."
    fi
else
    echo "Failed to create simulator v2."
fi
