function FindProxyForURL(url, host) {
  if (host ==  "%s") {
    return "PROXY %s:%d";
  } else {
    return "DIRECT";
  }
}
