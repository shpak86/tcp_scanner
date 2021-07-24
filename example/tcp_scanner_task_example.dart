import 'dart:async';

import 'package:tcp_scanner/tcp_scanner.dart';

main() async {
  var host = '192.168.88.229';
  var ports = List.generate(1000, (i) => 10 + i)
    ..add(5000)
    ..addAll([1100, 1110]);
  var stopwatch = Stopwatch();

   // Simple scan
  stopwatch.start();
  await TcpScannerTask(host, ports, shuffle: true, parallelism: 2)
      .start()
      .then((report) => print('Host $host scan complete\n'
          'Scanned ports:\t${report.ports.length}\n'
          'Open ports:\t${report.openPorts}\n'
          'Status:\t${report.status}\n'
          'Elapsed:\t${stopwatch.elapsed}\n'));

  // Cancel scan by delay
  ports = List.generate(50000, (i) => 10 + i);
  var scannerTask1 = TcpScannerTask(host, ports);

  stopwatch.start();
  Future.delayed(Duration(seconds: 1), () {
    print('ScannerTask cancelled by timeout after ${stopwatch.elapsed}');
    scannerTask1.cancel().then((report) => print('Host $host scan complete\n'
        'Scanned ports:\t${report.ports.length}\n'
        'Open ports:\t${report.openPorts}\n'
        'Status:\t${report.status}\n'
        'Elapsed:\t${stopwatch.elapsed}\n'));
  });
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
      var percents = 100.0*(report.openPorts.length + report.closedPorts.length) / report.ports.length;
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
}
