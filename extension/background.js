const urls = [
  'https://www.gate.io/*',
  'https://www.gate.com/*',
  'https://api.gateio.ws/*',
  'https://www.bitget.com/*',
  'https://api.bitget.com/*',
  'https://www.binance.com/*',
  'https://api.binance.com/*',
  'https://api.backpack.exchange/*',
  'https://omni.apex.exchange/*',
  'https://api.coinbase.com/*',
  'https://api.international.coinbase.com/*',
  'https://fapi.asterdex.com/*',
  'https://api.bybit.com/*',
  'https://api2.bybit.com/*',
  'https://api.mexc.com/*',
  'https://contract.mexc.com/*',
]

chrome.webRequest.onBeforeSendHeaders.addListener(
	(e) => ({
    requestHeaders: e.requestHeaders.filter(
      ({ name }) => name.toLowerCase() !== 'origin',
    ),
	}),
	{ urls },
	['blocking', 'requestHeaders', 'extraHeaders'],
)

chrome.webRequest.onHeadersReceived.addListener(
  (e) => {
    const headers = new Map(e.responseHeaders.map(({ name, value }) => [name.toLowerCase(), value]))
    headers.set('access-control-allow-origin', '*')
    headers.set('vary', 'Origin')
    headers.set('access-control-allow-credentials', 'true')
    headers.set('access-control-expose-headers', '*')
    if (e.method === 'OPTIONS') {
      headers.set('access-control-allow-methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS, HEAD')
      headers.set('access-control-allow-headers', '*')
      headers.set('access-control-max-age', '600')
    }
    const responseHeaders = Array.from(headers.entries()).map(([name, value]) => ({ name, value }))
    return { responseHeaders }
  },
  { urls },
  ['blocking', 'responseHeaders', 'extraHeaders']
)
