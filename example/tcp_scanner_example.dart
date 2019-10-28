import 'dart:async';

import 'package:tcp_scanner/tcp_scanner.dart';

main() {
  // HTTP ports scan
  TCPScanner("localhost", [
    80,
    8080,
    443
  ]).scan().then((result) {
    print("\nHTTP ports scan result");
    print("Host:          ${result.host}");
    print("Scanned ports: ${result.ports}");
    print("Open ports:    ${result.open}");
    print("Closed ports:  ${result.closed}");
    print("Elapsed time:  ${result.elapsed / 1000}s\n");
  });

  // Scan unreachable ports or hosts with connect timeout 300ms. Default timeout is 100ms.
  TCPScanner(
          "192.168.1.1",
          [
            80,
            8080,
            443
          ],
          timeout: 300)
      .scan()
      .then((result) {
    print("\nHTTP ports scan result");
    print("Host:          ${result.host}");
    print("Scanned ports: ${result.ports}");
    print("Open ports:    ${result.open}");
    print("Closed ports:  ${result.closed}");
    print("Elapsed time:  ${result.elapsed / 1000}s\n");
  });

  // Scan ports 20 - 1000
  TCPScanner.range("127.0.0.1", 20, 1000).scan().then((result) {
    print("\n20-1000 ports scan result");
    print("Host:           ${result.host}");
    print("Scanned ports:  20-1000");
    print("Open ports:     ${result.open}");
    print("Elapsed time:   ${result.elapsed / 1000}s\n");
  });

  // Scan ports range and display scan progress
  var tcpScanner = TCPScanner.range("127.0.0.1", 20, 5000);
  var timer = Timer.periodic(Duration(seconds: 1), (timer) {
    var scanProgress = 100.0 * (tcpScanner.scanResult.scanned.length / tcpScanner.scanResult.ports.length);
    print("Progress ${scanProgress.toStringAsPrecision(3)}%");
  });
  tcpScanner.scan().then((result) {
    timer.cancel();
    print("\n20-5000 ports scan result");
    print("Host:          ${result.host}");
    print("Scanned ports: 20-5000");
    print("Open ports:    ${result.open}");
    print("Elapsed time:  ${result.elapsed / 1000}s\n");
  });

  // Multithreading scan
  var multithreadedScanner = TCPScanner.range("127.0.0.1", 20, 5000, isolates: 10, shuffle: true);
  var multithreadedTimer = Timer.periodic(Duration(seconds: 1), (timer) {
    var scanProgress = 100.0 * (multithreadedScanner.scanResult.scanned.length / multithreadedScanner.scanResult.ports.length);
    print("Progress ${scanProgress.toStringAsPrecision(3)}%");
  });
  multithreadedScanner.scan().then((result) {
    multithreadedTimer.cancel();
    print("\n20-5000 ports scan result");
    print("Host:          ${result.host}");
    print("Scanned ports: 20-5000");
    print("Open ports:    ${result.open}");
    print("Elapsed time:  ${result.elapsed / 1000}s\n");
  });
}
