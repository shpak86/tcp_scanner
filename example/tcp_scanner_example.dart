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
        .then((report) => print('Host $host scan complete\n'
            'Scanned ports:\t${report.ports.length}\n'
            'Open ports:\t${report.openPorts}\n'
            'Status:\t${report.status}\n'
            'Elapsed:\t${stopwatch.elapsed}\n'))
        // Catch errors during the scan
        .catchError((error) => stderr.writeln(error));
  } on TcpScannerTaskException catch (e) {
    // Here you can catch exceptions threw in the constructor
    stderr.writeln('Error: ${e.cause}');
  }
/*
  // Cancel scan by delay
  ports = List.generate(50000, (i) => 10 + i);
  var scannerTask1 = TcpScannerTask(host, ports);
  stopwatch.start();
  Future.delayed(Duration(seconds: 2), () {
    print('ScannerTask cancelled by timeout after ${stopwatch.elapsed}');
    scannerTask1
        .cancel()
        .then((report) => print('Host $host scan was cancelled\n'
            'Scanned ports:\t${report.ports.length}\n'
            'Open ports:\t${report.openPorts}\n'
            'Status:\t${report.status}\n'
            'Elapsed:\t${stopwatch.elapsed}\n'))
        .catchError((error) => print(error.cause));
  });
  scannerTask1.start();

  // Get intermediate results
  ports = List.generate(50000, (i) => 10 + i);
  var scannerTask2 = TcpScannerTask(host, ports);
  stopwatch.start();
  Timer.periodic(Duration(seconds: 2), (timer) {
    scannerTask2.report.then((report) {
      var percents = 100.0 * (report.openPorts.length + report.closedPorts.length) / report.ports.length;
      print('Host $host scan progress ${percents.toStringAsFixed(1)}%\n'
          'Scanned ports:\t${report.ports.length}\n'
          'Open ports:\t${report.openPorts}\n'
          'Status:\t${report.status}\n'
          'Elapsed:\t${stopwatch.elapsed}\n');
      if (report.status == TcpScannerTaskReportStatus.finished) {
        timer.cancel();
      }
    });
  });
  await scannerTask2.start();

  // HTTP ports scan
  TCPScanner("localhost", [80, 8080, 443]).scan().then((result) {
    print("\nHTTP ports scan result");
    print("Host:          ${result.host}");
    print("Scanned ports: ${result.ports}");
    print("Open ports:    ${result.open}");
    print("Closed ports:  ${result.closed}");
    print("Elapsed time:  ${result.elapsed / 1000}s\n");
  });

  // Scan unreachable ports or hosts with connect timeout 300ms. Default timeout is 100ms.
  TCPScanner("192.168.1.1", [80, 8080, 443], timeout: 300).scan().then((result) {
    print("\nHTTP ports scan result");
    print("Host:          ${result.host}");
    print("Scanned ports: ${result.ports}");
    print("Open ports:    ${result.open}");
    print("Closed ports:  ${result.closed}");
    print("Elapsed time:  ${result.elapsed / 1000}s\n");
  });

  // Scan ports 20 - 1000
  TCPScanner.range("192.168.88.229", 20, 1000).scan().then((result) {
    print("\n20-1000 ports scan result");
    print("Host:           ${result.host}");
    print("Scanned ports:  20-1000");
    print("Open ports:     ${result.open}");
    print("Elapsed time:   ${result.elapsed / 1000}s\n");
  });

  // Scan ports range and display scan progress
  var tcpScanner = TCPScanner.range("127.0.0.1", 20, 50000, updateInterval: Duration(seconds: 1));
  var timer = Timer.periodic(Duration(seconds: 1), (timer) {
    var scanProgress = 100.0 * (tcpScanner.scanResult.scanned.length / tcpScanner.scanResult.ports.length);
    print("Progress ${scanProgress.toStringAsPrecision(3)}%");
  });
  tcpScanner.scan().then((result) {
    timer.cancel();
    print('''
      20-50000 ports scan result
      Host:          ${result.host}
      Scanned ports: 20-50000
      Open ports:    ${result.open}
      Elapsed time:  ${result.elapsed / 1000}s
      ''');
  });

  // Multithreading scan
  var multithreadedScanner = TCPScanner.range("127.0.0.1", 20, 5000, isolates: 5, shuffle: true);
  var multithreadedTimer = Timer.periodic(Duration(seconds: 1), (timer) {
    var scanProgress =
        100.0 * (multithreadedScanner.scanResult.scanned.length / multithreadedScanner.scanResult.ports.length);
    print("Progress ${scanProgress.toStringAsPrecision(3)}%");
  });
  multithreadedScanner.scan().then((result) {
    multithreadedTimer.cancel();
    print('''
    20-50000 ports scan result
    Host:          ${result.host}
    Scanned ports: 20-5000
    Open ports:    ${result.open}
    Elapsed time:  ${result.elapsed / 1000}s
    ''');
  });*/
}
