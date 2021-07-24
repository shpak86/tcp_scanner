enum TcpScannerTaskReportStatus { undefined, progress, finished, cancelled }

class TcpScannerTaskReport {
  final String host;
  final List<int> ports;
  final List<int> openPorts;
  final List<int> closedPorts;
  final TcpScannerTaskReportStatus status;

  TcpScannerTaskReport(this.host, this.ports, this.openPorts, this.closedPorts, this.status);
}
