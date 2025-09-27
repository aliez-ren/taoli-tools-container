#!/bin/sh

curl -fsSL https://get.docker.com | sh
curl -fsSL https://github.com/aliez-ren/taoli-tools-container/raw/refs/heads/main/chrome.json -o chromium.json
docker rm -f taoli-tools-container
docker run --name=taoli-tools-container  --security-opt seccomp=chromium.json -v $HOME/taoli-tools:/home/taoli/data -d ghcr.io/aliez-ren/taoli-tools-container:latest
docker logs -f taoli-tools-container
