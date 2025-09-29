# Taoli Tools Container

## Setup
```bash
curl -fsSL https://taoli.tools/setup | sh
```

## Update
```bash
docker pull ghcr.io/aliez-ren/taoli-tools-container:latest
docker service update --force taoli_tools_container
docker service logs -f taoli_tools_container
```

```bash
docker pull ghcr.io/aliez-ren/taoli-tools-signer:latest
docker service update --force taoli_tools_signer
docker service logs -f taoli_tools_signer
```

## Remove
```bash
docker service rm taoli_tools
```
