import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import '../domain/entities/report.dart';

class ScannerIsolate {
  static const String _status_message = 'status';
  final String host;
  final List<int> ports;
  final Duration socketTimeout;
  final ReceivePort _fromIsolate = ReceivePort();
  SendPort? _toIsolate;
  Isolate? _isolate;
  final Capability _capability = Capability();
  StreamController<Report> _streamController = StreamController<Report>();

  Stream<Report> get result => _streamController.stream;
  Report? _report;

  ScannerIsolate({
    required this.host,
    required this.ports,
    this.socketTimeout = const Duration(milliseconds: 100),
  });

  Future<Report> scan() async {
    var scanResult = StreamController<Report>();
    _fromIsolate.listen((message) {
      if (message is SendPort) {
        _toIsolate = message;
      } else {
        var result = message as Report;
        _streamController.add(result);
        if (result.status == ReportStatus.finished) {
          scanResult.add(result);
          _fromIsolate.close();
        }
      }
    });
    _isolate =
        await Isolate.spawn(_scan, ScannerIsolateArgs(sendPort: _fromIsolate.sendPort, host: host, ports: ports));
    _report = await scanResult.stream.first;
    terminate();
    return report;
  }

  Future<Report> get report async {
    var result;
    if (_report != null) {
      result = _report!;
    } else {
      result = Report(host, ports);
      if (_toIsolate != null) {
        _toIsolate?.send(_status_message);
        result = await _streamController.stream.first;
        _flushStreamController();
      }
    }
    return result;
  }

  void _flushStreamController() {
    _streamController.close();
    _streamController = StreamController();
  }

  void terminate() {
    _fromIsolate.close();
    _isolate?.kill();
  }

  void pause() {
    _isolate?.pause(_capability);
  }

  void resume() {
    _isolate?.resume(_capability);
  }

  static void _scan(ScannerIsolateArgs args) async {
    var fromMain = ReceivePort();
    var toMain = args.sendPort;
    var host = args.host;
    var ports = args.ports;
    var timeout = args.timeout;
    Socket? socket;
    var report = Report(host, ports, status: ReportStatus.progress);
    // Establish communication channel
    toMain.send(fromMain.sendPort);
    fromMain.listen((message) {
      if (message.toString() == _status_message) {
        toMain.send(report);
      }
    });
    // Scan ports
    for (var port in ports) {
      try {
        socket = await Socket.connect(host, port, timeout: timeout);
        report.addOpen(port: port);
      } catch (e) {
        report.addClosed(port: port);
      } finally {
        await socket?.close();
      }
    }
    // Send a report
    report.status = ReportStatus.finished;
    toMain.send(report);
  }
}

/// Scanner arguments class
class ScannerIsolateArgs {
  final SendPort sendPort;
  final String host;
  final List<int> ports;
  final Duration timeout;

  ScannerIsolateArgs({
    required this.sendPort,
    required this.host,
    required this.ports,
    this.timeout = const Duration(milliseconds: 100),
  });
}
