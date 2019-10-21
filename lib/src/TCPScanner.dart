import 'dart:io';

import 'ScanResult.dart';

/// TCP port scanner
class TCPScanner {
  /// Host to scan
  String _host;

  /// List of scanning ports
  List<int> _ports;

  /// Scan results
  ScanResult scanResult = ScanResult();
  Duration _connectTimeout;

  /// Prepares scanner to scan specified host and specified ports
  TCPScanner(this._host, this._ports, {int timeout = 100}) {
    _connectTimeout = Duration(milliseconds: timeout);
  }

  /// Prepares scanner to scan range of ports from startPort to endPort
  TCPScanner.range(this._host, int startPort, int endPort, {int timeout = 100}) {
    _connectTimeout = Duration(milliseconds: timeout);
    _ports = [];
    for (int port = startPort; port <= endPort; port++) {
      _ports.add(port);
    }
  }

  /// Execute scanning
  Future<ScanResult> scan() async {
    Socket connection;
    scanResult = ScanResult(host: _host, ports: _ports, status: ScanStatuses.scanning);
    for (int port in _ports) {
      try {
        connection = await Socket.connect(_host, port, timeout: _connectTimeout);
        scanResult.addOpen(port);
      } catch (e) {
        if (e.osError != null && e.osError.errorCode == 61) scanResult.addClosed(port);
      } finally {
        if (connection != null) connection.destroy();
        scanResult.addScanned(port);
      }
    }
    scanResult.status = ScanStatuses.finished;
    return scanResult;
  }
}
