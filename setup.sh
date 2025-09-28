#!/bin/sh

mkdir -p /etc/docker/seccomp/

echo "{\"seccomp-profile\": \"/etc/docker/seccomp/chromium.json\"}" > /etc/docker/daemon.json

curl -fsSL https://github.com/aliez-ren/taoli-tools-container/raw/refs/heads/main/chromium.json -o /etc/docker/seccomp/chromium.json

curl -fsSL https://get.docker.com | sh

curl -fsSL https://github.com/aliez-ren/taoli-tools-container/raw/refs/heads/main/compose.yml -o compose.yml

openssl req -new -newkey rsa:4096 -x509 -sha256 -days 365 -nodes -subj /CN=signer -addext 'subjectAltName=DNS:signer,IP:127.0.0.1' -out CERT.pem -keyout KEY.pem

if [ ! -f keychain.toml ]; then
  echo " " > keychain.toml
fi

docker swarm init

docker stack deploy -c compose.yml -d taoli_tools

rm -f keychain.toml KEY.pem

mv CERT.pem /mnt/

docker service logs -f taoli_tools_container
