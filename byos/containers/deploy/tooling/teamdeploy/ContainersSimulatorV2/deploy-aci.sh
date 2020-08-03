LOCATION=$1
RG=$2
NAME=$3
REGISTRY=$4
TAG=$5
ACR_NAME=$6
ACR_PASS=$7

sed -i -e 's/SIM_NAME/'${NAME}'/g' ./ContainersSimulatorV2/aci-deploy.yaml
sed -i -e 's/REGISTRY/'${REGISTRY}'/g' ./ContainersSimulatorV2/aci-deploy.yaml
sed -i -e 's/TAG/'${TAG}'/g' ./ContainersSimulatorV2/aci-deploy.yaml
sed -i -e 's/ACR_NAME/'${ACR_NAME}'/g' ./ContainersSimulatorV2/aci-deploy.yaml
sed -i -e 's ACR_PASS '${ACR_PASS}' g' ./ContainersSimulatorV2/aci-deploy.yaml

az container create --resource-group $RG --file ./ContainersSimulatorV2/aci-deploy.yaml --location $LOCATION
