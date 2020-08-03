declare state=""

while true
do
    state="$(az container show -g testDeploy-$1 --name teamdeploy --query instanceView.state -o tsv)"
    
    if [[ $state != "Running" ]]; then
        break
    fi
    sleep 1m
done

echo "Deployment terminated with the following state: $state"

if [[ $state != "Succeeded" ]]; 
then
    echo "$(az container logs -g testDeploy-$1 --name teamdeploy)"
    exit 1
fi

echo "Completed validating deployment."