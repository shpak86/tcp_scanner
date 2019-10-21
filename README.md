# TCP port scanner

Scanner performs sequential connect scan of specified ports or port ranges.

## Usage
To use this package add `tcp_scanner` as a dependency in your pubspec.yaml. To run scan use TCPScanner class. 
ScanResult contains scanning report. If you need to get running scan status, you have to use TCPScanner.scanResult field.

Scan specified ports:

```dart
import 'package:tcp_scanner/tcp_scanner.dart';

main() {
  TCPScanner("localhost", [ 80, 8080, 443 ]).scan().then((result) {
    print("\nHTTP ports scan result");
    print("Host:          ${result.host}");
    print("Scanned ports: ${result.ports}");
    print("Open ports:    ${result.open}");
    print("Closed ports:  ${result.closed}");
    print("Elapsed time:  ${result.elapsed / 1000}s\n");
  });
}
```

If host is reachable and ports are closed output will be:

```
HTTP ports scan result
Host:          localhost
Scanned ports: [80, 8080, 443]
Open ports:    []
Closed ports:  [80, 8080, 443]
Elapsed time:  0.03s
```

If you scan unreachable hosts, ports are not added to `closed` list. You can set timeout time using `timeout` argument in TCPScanner constructor. By default timeout is 100ms.
Scan below elapsed about 900 ms because it scans 3 ports with 300ms timeout. 
```dart
import 'package:tcp_scanner/tcp_scanner.dart';

main() {
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
}
```
Output:
```
HTTP ports scan result
Host:          192.168.1.1
Scanned ports: [80, 8080, 443]
Open ports:    []
Closed ports:  []
Elapsed time:  0.924s
```

Scan ports range:

```dart
import 'package:tcp_scanner/tcp_scanner.dart';

main() {
  TCPScanner.range("127.0.0.1", 20, 1000).scan().then((result) {
    print("\n20-1000 ports scan result");
    print("Host:           ${result.host}");
    print("Scanned ports:  20-1000");
    print("Open ports:     ${result.open}");
    print("Elapsed time:   ${result.elapsed / 1000}s\n");
  });
}
```

Getting information about running scan:

```dart
import 'dart:async';
import 'package:tcp_scanner/tcp_scanner.dart';

main() {
  var tcpScanner = TCPScanner.range("127.0.0.1", 20, 5000);
  var timer = Timer.periodic(Duration(seconds: 2), (timer) {
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
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/shpak86/tcp_scanner/issues
