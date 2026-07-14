import 'dart:io';

import 'package:app_core/app_core.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkInfoImpl implements NetworkInfo {
  static const _validConnection = [
    ConnectivityResult.mobile,
    ConnectivityResult.wifi,
    ConnectivityResult.ethernet,
    ConnectivityResult.satellite,
  ];

  final Connectivity _connectivity;

  NetworkInfoImpl({required Connectivity connectivity})
    : _connectivity = connectivity;

  @override
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return results.any((result) => _validConnection.contains(result));
  }

  @override
  Future<bool> get isWifiConnected async {
    final results = await _connectivity.checkConnectivity();
    return results.contains(ConnectivityResult.wifi);
  }

  @override
  Future<bool> get hasInternetAccess async {
    final hasInterface = await isConnected;
    if (!hasInterface) return false;

    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
