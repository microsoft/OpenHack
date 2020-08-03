#!/bin/bash
set -xeuo pipefail
IFS=$'\n\t'

declare azureUserName=""
declare azurePassword=""
declare subscriptionId=""
declare resourceGroupLocation=""
declare recipientEmail=""
declare chatConnectionString=""
declare chatMessageQueue=""
declare tenantId=""
declare resourceGroupName=""
declare proctorResourceGroup=""

# Initialize parameters specified from command line
while getopts ":c:s:l:i:q:r:u:p:t:g:o:" arg; do
    case "${arg}" in
        c)
            chatConnectionString=${OPTARG}
        ;;
        s)
            subscriptionId=${OPTARG}
        ;;
        l)
            resourceGroupLocation=${OPTARG}
        ;;
        i)
            simulatorResourceGroupLocation=${OPTARG}
        ;;
        q)
            chatMessageQueue=${OPTARG}
        ;;
        r)
            recipientEmail=${OPTARG}
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
        g)
            resourceGroupName=${OPTARG}
        ;;
        o)
            proctorResourceGroup=${OPTARG}
        ;;
    esac
done
shift $((OPTIND-1))

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

declare proctorRG=""
if [[ -n "$proctorResourceGroup" ]]; then
    proctorRG="$proctorResourceGroup"
else
    proctorRG="ProctorVMRG"
fi

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
chatMessage="Information you'll need for challenges. You can find these later in the 'Messages' tab.</br></br>"

echo "=========================================="
echo " VARIABLES"
echo "=========================================="
echo "subscriptionId                    = "${subscriptionId}
echo "resourceGroup                     = "${resourceGroupName}
echo "resourceGroupLocation             = "${resourceGroupLocation}
echo "simulatorResourceGroupLocation    = "${simulatorResourceGroupLocation}
echo "registryName                      = "${registryName}
echo "sqlServerName                     = "${sqlServerName}
echo "sqlServerUsername                 = "${sqlServerUsername}
echo "sqlDBName                         = "${sqlDBName}
echo "recipientEmail                    = "${recipientEmail}
echo "chatConnectionString              = "${chatConnectionString}
echo "chatMessageQueue                  = "${chatMessageQueue}
echo "simulatorName                     = "${simulatorName}
echo "tenantId                          = "${tenantId}
echo "proctorResourceGroup              = "${proctorResourceGroup}

#login to azure using your credentials
echo "Username: $azureUserName"

if [[ -z "${tenantId}" ]]; then
    az login --username=$azureUserName --password=$azurePassword
else
    az login --service-principal --username=$azureUserName --password=$azurePassword --tenant=$tenantId
fi

# Setting sub:
echo "Setting sub to ${subscriptionId}..."
az account set -s $subscriptionId 

echo "Registering preview features..."
az feature register --name APIServerSecurityPreview --namespace Microsoft.ContainerService
az feature register --name WindowsPreview --namespace Microsoft.ContainerService
az feature register --name PodSecurityPolicyPreview --namespace Microsoft.ContainerService

echo "Registering providers required..."
az provider register --namespace Microsoft.OperationsManagement

echo "Creating resource group ($resourceGroupName) in $resourceGroupLocation..."
az group create -n $resourceGroupName -l $resourceGroupLocation

domain=$(cut -d "@" -f 2 <<< $azureUserName)
if [[ "${recipientEmail}" != "\"\"" &&  "${chatConnectionString}" != "\"\"" && "${chatMessageQueue}" != "\"\"" ]]; then
    echo "Creating webdev and apidev users..."
    apidevObjectId=$(az ad user create --display-name api-dev --password $apidevpassword --user-principal-name apidev@$domain --query objectId -o tsv)

    webdevObjectId=$(az ad user create --display-name web-dev --password $webdevpassword --user-principal-name webdev@$domain --query objectId -o tsv)
    if [ $? == 0 ];
    then
        chatMessage="$chatMessage Web-dev User: webdev@$domain</br>Web-dev PW: $webdevpassword</br>Api-dev User: apidev@$domain</br>Api-dev PW: $apidevpassword</br></br>"
    fi
fi
# Create ACR
echo "Creating Azure Container Registry..."
ACR=$(az acr create -n $registryName -g $resourceGroupName -l $resourceGroupLocation --sku Basic -o json)

if [ $? == 0 ];
then
    echo "Azure Container Registry" $registryName "created successfully..."
    # This step so that we don't need to do role assignement
    echo "Enable Registry for admin authentication"
    az acr update -n $registryName --admin-enabled true

    az acr build --registry $registryName --image insurance:1.0 insuranceapp-monitoring --no-wait
    az acr build --registry $registryName --image wcfservice:1.0 WinLegacyApp --platform Windows --no-wait
    az acr build --registry $registryName --image tripviewer2:1.0 tripviewer2 --no-wait

    # Replace hard coded localhost in simulator webpage
    FQDN='simulator'${registryName}'.'${resourceGroupLocation}'.azurecontainer.io'
    sed -i -e 's localhost '${FQDN}' g' ./ContainersSimulatorV2/views/index.html

    az acr build --registry $registryName --image simulator:1.0 ContainersSimulatorV2 -f ContainersSimulatorV2/Dockerfile --no-wait
    az acr build --registry $registryName --image prometheus-sim:1.0 ContainersSimulatorV2 -f ContainersSimulatorV2/Dockerfile.prometheus --no-wait
    az acr build --registry $registryName --image grafana-sim:1.0 ContainersSimulatorV2 -f ContainersSimulatorV2/Dockerfile.grafana --no-wait

fi

# Create VNET
echo "Creating VNET with VM..."
az network vnet create -g $resourceGroupName -n vnet --address-prefix 10.2.0.0/22 --subnet-name vm-subnet --subnet-prefix 10.2.0.0/24

if [ $? == 0 ];
then
    echo "Azure VNET created successfully."
fi

# Create VM
az vm create -n internal-vm -g $resourceGroupName --admin-username azureuser --generate-ssh-keys --public-ip-address "" --image UbuntuLTS --vnet-name vnet --subnet vm-subnet

if [ $? == 0 ];
then
    echo "VM created successfully in subnet"
fi

# Create Azure SQL Server instance
echo "Creating Azure SQL Server instance..."
az sql server create -l $resourceGroupLocation -g $resourceGroupName -n $sqlServerName -u $sqlServerUsername -p $sqlServerPassword

if [ $? == 0 ];
then
    echo "SQL Server created successfully."
    echo "Adding firewall rule to SQL server..."
    az sql server firewall-rule create --resource-group $resourceGroupName --server $sqlServerName -n "Allow Access To Azure Services" --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0
    
    if [ $? == 0 ];
    then
        echo "Firewall rule added successfully to SQL server."
    else
        echo "Failed to add firewall rule to SQL server."
    fi

    # Create Azure SQL DB
    echo "Creating Azure SQL DB..."
    az sql db create -g $resourceGroupName -s $sqlServerName -n $sqlDBName

    if [ $? == 0 ];
    then
        echo "SQL database created successfully."
        az container create -g $proctorRG --name dataload --image $dataLoadImage --secure-environment-variables SQLFQDN=$sqlServerName.database.windows.net SQLUSER=$sqlServerUsername SQLPASS=$sqlServerPassword SQLDB=$sqlDBName
        chatMessage="$chatMessage Azure SQL FDQN: $sqlServerName.database.windows.net</br>Azure SQL Server User: $sqlServerUsername</br>Azure SQL Server Pass: $sqlServerPassword</br>Azure SQL Server Database: $sqlDBName</br></br>"
    else
        echo "Failed to create SQL database."
    fi
else
    echo "Failed to create SQL Server."
fi

# Check on builds
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

# Create simulator
if [ $? == 0 ];
then
    ACR_PASS="$(az acr credential show -n $registryName --query 'passwords[0].value' --output tsv)"
    ./ContainersSimulatorV2/deploy-aci.sh $simulatorResourceGroupLocation $resourceGroupName $simulatorName $registryName.azurecr.io 1.0 $registryName $ACR_PASS
    simulatorfqdn=$(az container show -n $simulatorName -g $resourceGroupName --query 'ipAddress.fqdn' --out tsv)
    
    if [ $? == 0 ];
    then
        echo "Simulator v2 deployed to ACI successfully."
        chatMessage="$chatMessage Simulator url:$simulatorfqdn"
    else
        echo "Failed to deploy simulator v2 to ACI."
    fi
else
    echo "Failed to create simulator v2."
fi

if [[ $? == 0 ]] && [[ "${recipientEmail}" != "\"\"" && "${chatConnectionString}" != "\"\"" && "${chatMessageQueue}" != "\"\"" ]];
then
    echo "Send message to user..."
    ./send_msg.sh -n  -e $recipientEmail -c $chatConnectionString -q $chatMessageQueue -m $chatMessage

    echo "Finished deploying resources."
fi
