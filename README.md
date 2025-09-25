```bash
docker build -t chromium-kasmvnc .
docker run -p 80:80 --security-opt seccomp=chrome.json chromium-kasmvnc
```
