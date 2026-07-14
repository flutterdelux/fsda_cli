abstract interface class NetworkInfo {
  Future<bool> get isConnected;
  Future<bool> get isWifiConnected;
  Future<bool> get hasInternetAccess;
}
