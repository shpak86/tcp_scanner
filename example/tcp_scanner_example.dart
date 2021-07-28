import 'dart:async';
import 'dart:io';

import 'package:tcp_scanner/tcp_scanner.dart';

main() async {
  var host = '192.168.88.229';
  var ports = List.generate(1000, (i) => 10 + i)
    ..add(5000)
    ..addAll([1100, 1110]);
  var stopwatch = Stopwatch();
  stopwatch.start();

  // Simple scan
  try {
    await TcpScannerTask(host, ports, shuffle: true, parallelism: 2)
        .start()
        .then((report) => print('Host ${report.host} scan completed\n'
            'Scanned ports:\t${report.ports.length}\n'
            'Open ports:\t${report.openPorts}\n'
            'Status:\t${report.status}\n'
            'Elapsed:\t${stopwatch.elapsed}\n'))
        // Catch errors during the scan
        .catchError((error) => stderr.writeln(error));
  } catch (e) {
    // Here you can catch exceptions threw in the constructor
    stderr.writeln('Error: $e');
  }

  // Cancel scanning by delay
  ports = List.generate(50000, (i) => i);
  var scannerTask1 = TcpScannerTask(host, ports);
  stopwatch.start();
  try {
    Future.delayed(Duration(seconds: 2), () {
      print('ScannerTask cancelled by timeout after ${stopwatch.elapsed}');
      scannerTask1
          .cancel()
          .then((report) => print('Host ${report.host} scan was cancelled\n'
              'Scanned ports:\t${report.ports.length}\n'
              'Open ports:\t${report.openPorts}\n'
              'Status:\t${report.status}\n'
              'Elapsed:\t${stopwatch.elapsed}\n'))
          .catchError((error) => print(error));
    });
    scannerTask1.start();
  } catch (e) {
    print(e);
  }

  // Get reports during the scanning
  host = '192.168.88.229';
  ports = List.generate(65535, (i) => 0 + i);
  stopwatch = Stopwatch();
  stopwatch.start();
  try {
    var scannerTask2 = TcpScannerTask(host, ports, parallelism: 100);
    Timer.periodic(Duration(seconds: 1), (timer) {
      scannerTask2.report.then((report) {
        var percents = 100.0 * (report.openPorts.length + report.closedPorts.length) / report.ports.length;
        var scanned = report.closedPorts.length + report.openPorts.length;
        print('Host $host scan progress ${percents.toStringAsFixed(1)}%\n'
            'Scanned ports:\t$scanned of ${report.ports.length}\n'
            'Open ports:\t${report.openPorts}\n'
            'Status:\t${report.status}\n'
            'Elapsed:\t${stopwatch.elapsed}\n');
        if (report.status == TcpScannerTaskReportStatus.finished) {
          timer.cancel();
        }
      });
    });
    await scannerTask2.start();
  } catch (e) {
    print(e);
  }
}
