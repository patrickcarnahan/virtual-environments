#!/bin/bash
################################################################################
##  File:  docker-moby.sh
##  Desc:  Installs docker onto the image
################################################################################

source $HELPER_SCRIPTS/apt.sh
source $HELPER_SCRIPTS/document.sh

docker_package=moby
installed=0

## Check to see if docker is already installed
echo "Determing if Docker ($docker_package) is installed"
if ! IsInstalled $docker_package; then
    echo "Docker ($docker_package) was not found. Installing..."
    apt-get remove -y moby-engine moby-cli
    apt-get update
    apt-get install -y moby-engine moby-cli
    apt-get install --no-install-recommends -y moby-buildx
    installed=1
else
    echo "Docker ($docker_package) is already installed"
fi

# Run tests to determine that the software installed as expected
echo "Testing to make sure that script performed as expected, and basic scenarios work"
echo "Checking the docker-moby and moby-buildx"
if ! command -v docker; then
    echo "docker was not installed"
    exit 1
elif ! [[ $(docker buildx) ]]; then
    echo "Docker-Buildx was not installed"
    exit 1
elif [ $installed != 0 ]; then
    echo "Docker-moby and Docker-buildx checking the successfull"
    # Docker daemon takes time to come up after installing
    sleep 10
    set -e
    docker info
    set +e
fi

## Add version information to the metadata file
echo "Documenting Docker version"
docker_version=$(docker -v)
DocumentInstalledItem "Docker-Moby ($docker_version)"

echo "Documenting Docker-buildx version"
DOCKER_BUILDX_VERSION=$(docker buildx version | cut -d ' ' -f2)
DocumentInstalledItem "Docker-Buildx ($DOCKER_BUILDX_VERSION)"
