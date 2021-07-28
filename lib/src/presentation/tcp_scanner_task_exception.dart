class TcpScannerTaskException implements Exception {
  String cause;

  TcpScannerTaskException(this.cause);

  @override
  String toString() {
    return cause;
  }
}
