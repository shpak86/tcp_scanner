import 'dart:isolate';

/// Isolate scanner arguments
class IsolateArguments {
  SendPort sendPort;
  String host;
  List<int> ports;
  Duration timeout;

  IsolateArguments(this.sendPort, this.host, this.ports, this.timeout);
}
