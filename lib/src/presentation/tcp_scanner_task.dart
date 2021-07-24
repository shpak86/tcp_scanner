import 'dart:math';

import 'tcp_scanner_task_report.dart';
import '../domain/entities/report.dart';
import '../domain/interactor/scanner_isolate_interactor.dart';
import '../presentation/tcp_scanner_task_exception.dart';

class TcpScannerTask {
  final String host;
  late final List<int> ports;
  final Duration socketTimeout;
  final bool shuffle;
  late final int parallelism;
  bool _isRunning = false;
  final List<ScannerIsolateInteractor> _scanners = [];

  bool get isRunning => _isRunning;

  TcpScannerTask(this.host, List<int> ports,
      {this.socketTimeout = const Duration(seconds: 1), this.shuffle = false, int parallelism = 4}) {
    //  Copy ports list and shuffle them if it's needed
    var portsList = ports.toSet().toList();
    if (shuffle) portsList.shuffle();
    this.ports = portsList;
    // Calculate number of isolates. The number of isolates can't be more than the number of ports.
    this.parallelism = min(parallelism, ports.length);
  }

  /// Start scanning task
  Future<TcpScannerTaskReport> start() async {
    if (_isRunning) {
      throw TcpScannerTaskException('Scanning is in progress');
    }
    _isRunning = true;
    // Split the list of ports into sublists
    var portsPerScanner = (ports.length / parallelism).ceil();
    var sublistFirstIndex = 0;
    var sublistLastIndex = 0;
    while (sublistFirstIndex < ports.length) {
      sublistLastIndex = min(sublistFirstIndex + portsPerScanner, ports.length);
      var portsSublist = ports.sublist(sublistFirstIndex, sublistLastIndex);
      _scanners.add(ScannerIsolateInteractor(host, portsSublist,
          parallelism: parallelism, shuffle: shuffle, socketTimeout: socketTimeout));
      sublistFirstIndex = sublistLastIndex;
    }
    // Start scan for each sublist
    var reports = await Future.wait(_scanners.map((scanner) => scanner.scan()));
    // Collect results to the resulting report
    var scanReport = Report(host, ports, status: ReportStatus.finished);
    reports.forEach((report) {
      scanReport.addOpen(ports: report.openPorts);
      scanReport.addClosed(ports: report.closedPorts);
    });
    _isRunning = false;
    return _reportToTcpScannerTaskReport(scanReport);
  }

  /// Request scan report report
  Future<TcpScannerTaskReport> get report async {
    var scanReport = Report(host, ports);
    var reports = await Future.wait(_scanners.map((scanner) => scanner.report));
    reports.forEach((report) {
      scanReport.addOpen(ports: report.openPorts);
      scanReport.addClosed(ports: report.closedPorts);
      if (scanReport.status != ReportStatus.progress) {
        scanReport.status = report.status;
      }
    });
    return _reportToTcpScannerTaskReport(scanReport);
  }

  /// Cancel scanner task
  Future<TcpScannerTaskReport> cancel() async {
    var resultReport;
    if (_isRunning) {
      var scanReport = await report;
      resultReport = TcpScannerTaskReport(scanReport.host, scanReport.ports, scanReport.openPorts,
          scanReport.closedPorts, TcpScannerTaskReportStatus.cancelled);
      _scanners.forEach((scanner) => scanner.cancel());
      _isRunning = false;
    } else {
      throw TcpScannerTaskException('TcpScannerTask can\'t be cancelled');
    }
    return resultReport;
  }

  /// Map Report to TcpScannerTaskReport
  TcpScannerTaskReport _reportToTcpScannerTaskReport(Report report) {
    TcpScannerTaskReportStatus status;
    switch (report.status) {
      case ReportStatus.progress:
        status = TcpScannerTaskReportStatus.progress;
        break;
      case ReportStatus.finished:
        status = TcpScannerTaskReportStatus.finished;
        break;
      case ReportStatus.cancelled:
        status = TcpScannerTaskReportStatus.cancelled;
        break;
      default:
        status = TcpScannerTaskReportStatus.undefined;
        break;
    }
    return TcpScannerTaskReport(report.host, report.ports, report.openPorts, report.closedPorts, status);
  }
}
