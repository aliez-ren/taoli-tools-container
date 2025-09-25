chrome.webRequest.onHeadersReceived.addListener(
  (e) => {
    const headers = new Map(e.responseHeaders.map(({ name, value }) => [name.toLowerCase(), value]))
    headers.set("access-control-allow-origin", "*")
    headers.set("vary", "Origin")
    headers.set("access-control-allow-credentials", "true")
    headers.set("access-control-expose-headers", "*")
    if (e.method === "OPTIONS") {
      headers.set("access-control-allow-methods", "GET, POST, PUT, PATCH, DELETE, OPTIONS, HEAD")
      headers.set("access-control-allow-headers", "*")
      headers.set("access-control-max-age", "600")
    }
    const responseHeaders = Array.from(headers.entries()).map(([name, value]) => ({ name, value }))
    return { responseHeaders }
  },
  { urls: ["<all_urls>"] },
  ["blocking", "responseHeaders", "extraHeaders"]
)
