# TCP port scanner

This is simple TCP port scanner. Library allows you to get scan status during the scanning. You can use single scan thread or define number of threads to improve perfomance.

## Usage

To use this package you have to add `tcp_scanner` as a dependency in your `pubspec.yaml`.
It's easy to scan a host. You just need to create the `TCPScanner` instance and call `scan` method. The result is stored in `ScanResult` data object.

Scan specified ports:

```dart
import 'package:tcp_scanner/tcp_scanner.dart';

main() {
  TCPScanner("localhost", [ 80, 8080, 443 ]).scan().then((result) {
    print('''
HTTP ports scan result
Host:          ${result.host}
Scanned ports: ${result.ports}
Open ports:    ${result.open}
Closed ports:  ${result.closed}
Elapsed time:  ${result.elapsed / 1000}s
''');
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

Sometimes you can not get response from the host or from specified port because of firewall or IDS. In this case port will be marked as `closed`. To define connection establishment timeout you should use `timeout` argumnet in the constructor. By default, timeout is 100ms.

Scan in the following example elapsed about 900 ms because it was scanned 3 ports of the unreachable host with 300ms timeout.

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
          timeout: 100)
      .scan()
      .then((result) {
    print('''
HTTP ports scan result
Host:          ${result.host}
Scanned ports: ${result.ports}
Open ports:    ${result.open}
Closed ports:  ${result.closed}
Elapsed time:  ${result.elapsed / 1000}s
''');
  });
}
```

Output:

```
HTTP ports scan result
Host:          192.168.1.1
Scanned ports: [80, 8080, 443]
Open ports:    []
Closed ports:  [80, 8080, 443]
Elapsed time:  1.016s
```

You can use `TCPScanner.range` constructor if you want to scan ports range:

```dart
import 'package:tcp_scanner/tcp_scanner.dart';

main() {
  TCPScanner.range("127.0.0.1", 20, 1000).scan().then((result) {
    print('''
20-1000 ports scan result
Host:           ${result.host}
Scanned ports:  20-1000
Open ports:     ${result.open}
Elapsed time:   ${result.elapsed / 1000}s
''');
  });
}
```

You can get the current status while scan is running. Just use `TCPScanner.scanResult` to get current status. You can control update interval by `updateInterval` parameter. By default, update interval is 1 second. Getting information about running scan:

```dart
import 'dart:async';
import 'package:tcp_scanner/tcp_scanner.dart';

main() {
  var tcpScanner = TCPScanner.range("127.0.0.1", 20, 50000, updateInterval: Duration(seconds: 5));
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
}
```

Output:

```
Progress 0.00%
Progress 7.99%
Progress 18.2%
Progress 28.2%
Progress 38.2%
Progress 48.8%
Progress 59.6%
Progress 70.4%
Progress 81.1%
20-50000 ports scan result
Host:          127.0.0.1
Scanned ports: 20-50000
Open ports:    [1024, 1025, 1026, 1027, 1028, 1029, 29754]
Elapsed time:  9.841s
```

You can improve perfomance by set `isolates` argument. Also, you can shuffle ports using `shuffle` option.

```dart
  var multithreadedScanner = TCPScanner.range("127.0.0.1", 20, 5000, isolates: 10, shuffle: true);
  var multithreadedTimer = Timer.periodic(Duration(seconds: 1), (timer) {
    var scanProgress = 100.0 * (multithreadedScanner.scanResult.scanned.length / multithreadedScanner.scanResult.ports.length);
    print("Progress ${scanProgress.toStringAsPrecision(3)}%");
  });
  multithreadedScanner.scan().then((result) {
    multithreadedTimer.cancel();
    print('''
20-5000 ports scan result
Host:          ${result.host}
Scanned ports: 20-5000
Open ports:    ${result.open}
Elapsed time:  ${result.elapsed / 1000}s
''');
  });
```

Open ports is shuffled in the report because `shuffle` option was used and ports were scanned in a random order. Ports will be shuffled each call of `scan()`.

```
Progress 0.00%
Progress 21.5%
Progress 52.4%
20-50000 ports scan result
Host:          127.0.0.1
Scanned ports: 20-50000
Open ports:    [1028, 1029, 1024, 1027, 29754, 1026, 1025]
Elapsed time:  3.535s
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/shpak86/tcp_scanner/issues
