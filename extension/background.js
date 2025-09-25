// Reflect request Origin and Access-Control-Request-Headers into the response.
// WARNING: Dev/testing only.

const ORIGIN_MAP = new Map(); // requestId -> origin
const ACRH_MAP = new Map();   // requestId -> access-control-request-headers
const ENABLE_KEY = "enabled";
const SCOPE_KEY = "scopes"; // array of URL match patterns; empty => all

async function getConfig() {
  const { [ENABLE_KEY]: enabled = true, [SCOPE_KEY]: scopes = [] } =
    await chrome.storage.local.get([ENABLE_KEY, SCOPE_KEY]);
  return { enabled, scopes };
}

function urlMatchesScopes(url, scopes) {
  if (!scopes || scopes.length === 0) return true; // no scopes => match all
  return scopes.some(pattern => {
    try { return new URL(url).href.match(new RegExp(pattern)); }
    catch { return false; }
  });
}

chrome.webRequest.onBeforeSendHeaders.addListener(
  async (details) => {
    const { enabled, scopes } = await getConfig();
    if (!enabled || !urlMatchesScopes(details.url, scopes)) return;

    let origin = null;
    let acrh = null;

    for (const h of details.requestHeaders || []) {
      if (h.name.toLowerCase() === "origin") origin = h.value;
      if (h.name.toLowerCase() === "access-control-request-headers") acrh = h.value;
    }
    if (origin) ORIGIN_MAP.set(details.requestId, origin);
    if (acrh) ACRH_MAP.set(details.requestId, acrh);

    // no header mutations required here, but we could add/remove if needed
    return { requestHeaders: details.requestHeaders };
  },
  { urls: ["<all_urls>"] },
  ["blocking", "requestHeaders"]
);

chrome.webRequest.onHeadersReceived.addListener(
  async (details) => {
    const { enabled, scopes } = await getConfig();
    if (!enabled || !urlMatchesScopes(details.url, scopes)) return;

    const isPreflight = details.method === "OPTIONS";
    const origin = ORIGIN_MAP.get(details.requestId) || "*";
    const reqACRH = ACRH_MAP.get(details.requestId) || "";

    // Build new response headers map (case-insensitive replace)
    const newHeaders = [];
    const lower = new Map();
    for (const h of details.responseHeaders || []) {
      const key = h.name.toLowerCase();
      if (!lower.has(key)) lower.set(key, []);
      lower.get(key).push(h);
    }
    function setHeader(name, value) {
      const key = name.toLowerCase();
      lower.set(key, [{ name, value }]);
    }

    // CORS relaxation
    // If you need credentials (cookies) with CORS, "*" is invalid for ACAO; reflect exact Origin instead.
    const allowOrigin = origin === "null" ? "*" : origin;
    setHeader("Access-Control-Allow-Origin", allowOrigin);
    setHeader("Vary", "Origin"); // keep caches sane
    setHeader("Access-Control-Allow-Credentials", "true");
    setHeader("Access-Control-Expose-Headers", "*");

    if (isPreflight) {
      setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, PATCH, DELETE, OPTIONS, HEAD");
      setHeader("Access-Control-Allow-Headers", reqACRH || "*");
      setHeader("Access-Control-Max-Age", "600");
    }

    // Reconstruct list
    for (const [_, arr] of lower) newHeaders.push(...arr);

    // cleanup maps to avoid leaks
    ORIGIN_MAP.delete(details.requestId);
    ACRH_MAP.delete(details.requestId);

    return { responseHeaders: newHeaders };
  },
  { urls: ["<all_urls>"] },
  ["blocking", "responseHeaders"]
);
