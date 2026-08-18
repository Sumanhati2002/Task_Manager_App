import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'task_services.dart';

class ConnectivityService implements NetworkStatusService {
  ConnectivityService({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  @override
  Stream<bool> get onlineStatus {
    return _connectivity.onConnectivityChanged.map(_hasConnection);
  }

  @override
  Future<bool> get isOnline async {
    final result = await _connectivity.checkConnectivity();
    return _hasConnection(result);
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    return results.any((result) => result != ConnectivityResult.none);
  }
}
