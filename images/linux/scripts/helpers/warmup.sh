#!/bin/bash

sudo systemctl stop docker
echo "{}" | jq '. += { "data-root": "/mnt/docker" }' | sudo tee /etc/docker/daemon.json
sudo systemctl start docker

# we need to load the images into the new daemon storage location on the SSD
if -d ~/data/docker-images; then
    echo "Loading images .."

    for i in ~/data/docker-images/*.tar; do
        docker image load -i "$i"
    done
fi

pwsh -File ~/actions-warmup.ps1 >> ~/actions-warmup.log