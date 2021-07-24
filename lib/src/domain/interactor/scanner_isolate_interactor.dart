import 'dart:async';

import '../../data/scanner_isolate.dart';
import '../entities/report.dart';
import 'use_case.dart';

class ScannerIsolateInteractor implements UseCase {
  final String host;
  final List<int> ports;
  final int parallelism;
  final bool shuffle;
  final Duration socketTimeout;

  late ScannerIsolate _scannerIsolate;

  ScannerIsolateInteractor(this.host, this.ports,
      {this.parallelism = 4, this.shuffle = false, this.socketTimeout = const Duration(milliseconds: 100)}) {
    _scannerIsolate = ScannerIsolate(host: host, ports: ports, socketTimeout: socketTimeout);
  }

  @override
  void cancel() {
    _scannerIsolate.terminate();
  }

  @override
  Future<Report> scan() => _scannerIsolate.scan();

  @override
  Future<Report> get report => _scannerIsolate.report;

}
