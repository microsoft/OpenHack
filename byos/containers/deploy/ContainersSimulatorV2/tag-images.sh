REPO=$1
TAG=$2

docker tag grafana-sim $REPO/grafana-sim:$TAG
docker tag prometheus-sim $REPO/prometheus-sim:$TAG
docker tag simulator $REPO/simulator:$TAG