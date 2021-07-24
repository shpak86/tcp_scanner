enum ReportStatus { undefined, progress, finished, cancelled }

class Report {
  final String host;
  final List<int> ports;
  late List<int> openPorts;
  late List<int> closedPorts;
  ReportStatus status;

  Report(this.host, this.ports, {List<int>? openPorts, List<int>? closedPorts, this.status = ReportStatus.undefined}) {
    this.openPorts = openPorts ?? [];
    this.closedPorts = closedPorts ?? [];
  }

  void addOpen({int? port, List<int>? ports}) {
    if (port != null) {
      openPorts.add(port);
    }
    if (ports != null) {
      openPorts.addAll(ports);
    }
  }

  void addClosed({int? port, List<int>? ports}) {
    if (port != null) {
      closedPorts.add(port);
    }
    if (ports != null) {
      closedPorts.addAll(ports);
    }
  }
}
