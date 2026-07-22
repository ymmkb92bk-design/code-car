import 'package:connectivity_plus/connectivity_plus.dart';

/// Network status detection (Section 4.6).
class ConnectivityService {
  static Stream<bool> get onStatusChange {
    return Connectivity().onConnectivityChanged.map(_isOnline);
  }

  static Future<bool> checkNow() async {
    final result = await Connectivity().checkConnectivity();
    return _isOnline(result);
  }

  static bool _isOnline(List<ConnectivityResult> results) {
    return results.any((r) => r != ConnectivityResult.none);
  }
}
