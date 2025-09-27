```bash
docker build -t taoli-tools-container .
docker volume create taoli-tools-data
docker run --security-opt seccomp=chrome.json -v taoli-tools-data:/home/taoli/data taoli-tools-container
```
