import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:tcp_scanner/src/IsolateArguments.dart';

import 'ScanResult.dart';

/// TCP port scanner
class TCPScanner {
  /// Host to scan
  String _host = '';

  /// List of scanning ports
  List<int> _ports = [];

  /// Scan results
  ScanResult _scanResult = ScanResult();

  /// Connection timeout. If the port doesn't receive an answer during this period it will be marked as unreachable.
  Duration _connectTimeout = Duration(microseconds: 100);

  /// Shuffle each scan
  late bool _shuffle;

  /// Count of isolates
  late int _isolatesCount;

  /// Isolates ScanResults
  List<ScanResult> _isolateScanResults = [];

  /// Prepares scanner to scan specified host and specified ports
  TCPScanner(String host, List<int> ports, {int timeout = 100, bool shuffle = false, int isolates = 1}) {
    _build(host, ports, timeout: timeout, shuffle: shuffle, isolates: isolates);
  }

  /// Prepares scanner to scan range of ports from startPort to endPort
  TCPScanner.range(String host, int startPort, int endPort, {int timeout = 100, bool shuffle = false, int isolates = 1}) {
    var ports = List.generate(max(startPort, endPort) + 1 - min(startPort, endPort), (i) => min(startPort, endPort) + i);
    _build(host, ports, timeout: timeout, shuffle: shuffle, isolates: isolates);
  }

  /// Build scan settings
  void _build(String host, List<int> ports, {int timeout = 100, bool shuffle = false, int isolates = 1}) {
    _host = host;
    _ports = ports;
    _connectTimeout = Duration(milliseconds: timeout);
    _shuffle = shuffle;
    _isolatesCount = isolates;
  }

  /// Return scan status
  ScanResult get scanResult {
    var result = ScanResult(status: ScanStatuses.finished);
    _isolateScanResults.forEach((isolateResult) {
      result.host = isolateResult.host;
      result..ports.addAll(isolateResult.ports)..scanned.addAll(isolateResult.scanned)..open.addAll(isolateResult.open)..closed.addAll(isolateResult.closed);
    });
    result.status = _scanResult.status;
    result.elapsed = _scanResult.elapsed;
    return result;
  }

  /// Execute scanning with at least 1 isolates
  Future<ScanResult> scan() async {
    // Prepare port ranges for isolates
    int isolatesCount = _isolatesCount;
    List<List<int>> isolatePorts = [];
    int portsPerIsolate = (_ports.length / isolatesCount).ceil();
    int startIndex = 0, endIndex = 0;
    List<int> ports = List.from(_ports);
    if (_shuffle) ports.shuffle();
    while (startIndex < ports.length) {
      endIndex = startIndex + portsPerIsolate > ports.length ? ports.length : startIndex + portsPerIsolate;
      isolatePorts.add(ports.sublist(startIndex, endIndex));
      startIndex = endIndex;
    }
    // Scan result
    _isolateScanResults = [];
    _scanResult = ScanResult(host: _host, ports: _ports, status: ScanStatuses.scanning);
    // Run isolates and create listeners
    var completers = <Completer>[];
    for (List<int> portsList in isolatePorts) {
      var completer = Completer();
      var receivePort = ReceivePort();
      var isolateScanResult = ScanResult(host: _host, ports: portsList, status: ScanStatuses.scanning);
      completers.add(completer);
      _isolateScanResults.add(isolateScanResult);
      await Isolate.spawn(_isolateScan, IsolateArguments(receivePort.sendPort, _host, portsList, _connectTimeout));
      receivePort.listen((result) {
        // When response received add information to scanResult
        isolateScanResult.scanned = result.scanned;
        isolateScanResult.open = result.open;
        isolateScanResult.closed = result.closed;
        isolateScanResult.status = result.status;
        if (result.status == ScanStatuses.finished) {
          receivePort.close();
          completer.complete(result);
        }
      });
    }
    // Wait until all isolates finished
    await Future.wait(completers.map((completer) => completer.future));
    _scanResult.status = ScanStatuses.finished;
    completers.clear();
    return scanResult;
  }

  /// Execute scanning with no isolates
  Future<ScanResult> noIsolateScan() async {
    Socket? connection;
    final scanResult = ScanResult(host: _host, ports: _ports, status: ScanStatuses.scanning);
    for (var port in _ports) {
      try {
        connection = await Socket.connect(_host, port, timeout: _connectTimeout);
        scanResult.addOpen(port);
      } catch (e) {
        scanResult.addClosed(port);
      } finally {
        if (connection != null) connection.destroy();
        scanResult.addScanned(port);
      }
    }
    scanResult.status = ScanStatuses.finished;
    return scanResult;
  }

  /// Isolated port scanner
  static void _isolateScan(IsolateArguments arguments) async {
    var scanResult = ScanResult(host: arguments.host, ports: arguments.ports, status: ScanStatuses.scanning);
    Socket? connection;
    var timer = Timer.periodic(Duration(seconds: 1), (timer) {
      arguments.sendPort.send(scanResult);
    });
    for (int port in arguments.ports) {
      if (port <= 0 || port > 65536) {
        scanResult.status = ScanStatuses.finished;
        arguments.sendPort.send(scanResult);
        timer.cancel();
        throw Exception('Invalid port: $port');
      } else {
        try {
          connection = await Socket.connect(arguments.host, port, timeout: arguments.timeout);
          scanResult.addOpen(port);
        } catch (e) {
          scanResult.addClosed(port);
        } finally {
          if (connection != null) connection.destroy();
          scanResult.addScanned(port);
        }
      }
    }
    scanResult.status = ScanStatuses.finished;
    arguments.sendPort.send(scanResult);
    timer.cancel();
  }
}
