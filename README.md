```bash
docker build -t taoli-tools-container .
docker run --security-opt seccomp=chrome.json -v=$HOME/taoli-tools:/home/taoli/data taoli-tools-container
```
