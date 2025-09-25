```bash
docker build -t chromium-novnc .
docker run -p 80:80 --security-opt seccomp=chrome.json chromium-novnc
```
