#!/bin/sh

curl -fsSL https://get.docker.com | sh
curl -fsSL https://github.com/aliez-ren/taoli-tools-container/raw/refs/heads/main/chromium.json -o chromium.json
docker rm -f taoli-tools-container
docker volume create taoli-tools-data
docker volume create tailscale-state
docker run --name=taoli-tools-container --security-opt seccomp=chromium.json -v taoli-tools-data:/home/taoli/data -v tailscale-state:/var/lib/tailscale -d --restart=always ghcr.io/aliez-ren/taoli-tools-container:latest
docker logs -f --tail 100 taoli-tools-container
