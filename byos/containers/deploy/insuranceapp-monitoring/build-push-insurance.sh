#!/bin/bash
# Docker instructions to build and push the image
set -e
# Uncomment next line and put your registry in

DOCKER_REGISTRY="${DOCKER_REGISTRY}"
TAG="1.0"
IMAGE="$DOCKER_REGISTRY.azurecr.io/insurance:$TAG"
PASS="${PASS}"

echo "$PASS" | docker login -u $DOCKER_REGISTRY --password-stdin $DOCKER_REGISTRY.azurecr.io

echo "Building and deploying $IMAGE"
[ -z "$DOCKER_REGISTRY" ] && echo "Error: \$DOCKER_REGISTRY must be specified." && exit 1
docker build -t $IMAGE .
docker push $IMAGE

echo "Image has been pushed as:"
echo "$IMAGE"