import 'dart:isolate';

/// Isolate scanner arguments
class IsolateArguments {
  final SendPort sendPort;
  final String host;
  final List<int> ports;
  final Duration timeout;
  final Duration updateInterval;

  IsolateArguments(this.sendPort, this.host, this.ports, this.timeout, {this.updateInterval = const Duration(seconds: 1)});
}
