REPO=$1
TAG=$2

docker push $REPO/grafana-sim:$TAG
docker push $REPO/prometheus-sim:$TAG
docker push $REPO/simulator:$TAG