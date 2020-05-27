#!/bin/bash

sudo systemctl stop docker
echo "{}" | jq '. += { "data-root": "/mnt/docker" }' | sudo tee /etc/docker/daemon.json
sudo systemctl start docker

# we need to load the images into the new daemon storage location on the SSD
if -d ~/data/docker-images; then
    echo "[$(date +%T)] Loading images" >> ~/actions-warmup.log

    for i in ~/data/docker-images/*.tar; do
        echo "[$(date +%T)] Loading image $i" >> ~/actions-warmup.log
        docker image load -i "$i"
        echo "[$(date +%T)] Finished loading image $i" >> ~/actions-warmup.log
    done

    echo "[$(date +%T)] Finished loading images" >> ~/actions-warmup.log
fi

pwsh -File ~/actions-warmup.ps1 >> ~/actions-warmup.log