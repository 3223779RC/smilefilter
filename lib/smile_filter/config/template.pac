function FindProxyForURL(url, host) {
  if (dnsDomainIs(host, “%s”)) {
    return "PROXY %s:%d";
  } else {
    return "DIRECT";
  }
}
