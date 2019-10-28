import 'dart:convert';

/// Scanning statuses
enum ScanStatuses { unknown, scanning, finished }

/// Scan result contains data of prepared, continuous or finished scanning.
class ScanResult {
  /// Host
  String host;

  /// All exploring ports
  List<int> ports = [];

  /// Ports that could be connected
  List<int> open = [];

  /// Ports that couldn't be connected
  List<int> closed = [];

  /// Ports which was scanned. This field is modifies when scan is in progress.
  List<int> scanned = [];

  /// Elapsed time. It can be null if scanning is in progress.
  int _elapsed;

  /// Time when status changed to scanning
  DateTime _startTime;

  /// Time when status changed to finished
  DateTime _finishTime;

  /// Current status
  ScanStatuses _status = ScanStatuses.unknown;

  /// Main constructor
  ScanResult({String host, List<int> ports, List<int> open, List<int> closed, List<int> scanned, ScanStatuses status}) {
    if (host != null) this.host = host;
    if (ports != null) this.ports = ports;
    if (open != null) this.open = open;
    if (closed != null) this.closed = closed;
    if (scanned != null) this.scanned = scanned;
    if (status != null) this.status = status;
    if (this.status == ScanStatuses.scanning) _startTime = DateTime.now();
  }

  /// Creation object from JSON
  ScanResult.fromJson(String json) {
    fromJson(json);
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson() {
    String statusString = "unknown";
    if (_status == ScanStatuses.scanning) {
      statusString = "scanning";
    } else if (_status == ScanStatuses.finished) {
      statusString = "finished";
    }
    return {
      "host": host,
      "ports": ports,
      "scanned": scanned,
      "open": open,
      "closed": closed,
      "elapsed": elapsed,
      "status": statusString
    };
  }

  /// Deserialize from JSON
  fromJson(String json) {
    Map<String, dynamic> map = jsonDecode(json);
    if (map.containsKey("host")) host = map["host"].toString();
    if (map.containsKey("ports")) ports = List<int>.from(map["ports"]);
    if (map.containsKey("scanned")) scanned = List<int>.from(map["scanned"]);
    if (map.containsKey("open")) open = List<int>.from(map["open"]);
    if (map.containsKey("closed")) closed = List<int>.from(map["closed"]);
    if (map.containsKey("elapsed")) _elapsed = map["elapsed"];
    if (map.containsKey("status")) {
      if (map["status"] == "finished") {
        _status = ScanStatuses.finished;
      } else if (map["status"] == "scanning") {
        _status = ScanStatuses.scanning;
      } else {
        _status = ScanStatuses.unknown;
      }
    }
  }

  /// Add single port
  addPort(int port) => ports.add(port);

  /// Add open port
  addOpen(int port) => open.add(port);

  /// Add closed port
  addClosed(int port) => closed.add(port);

  /// Add scanned port
  addScanned(int port) => scanned.add(port);

  /// Sets status, and modifies startTime and finishTime. If status is finished then modifies _elapsedTime.
  set status(value) {
    _status = value;
    if (value == ScanStatuses.scanning) {
      _startTime = DateTime.now();
    } else if (value == ScanStatuses.finished) {
      _finishTime = DateTime.now();
      // If the start time is undefined set it the same as the end time
      if (_startTime == null) _startTime = _finishTime;
      _elapsed = _finishTime.difference(_startTime).inMilliseconds;
    }
  }

  /// Returns current scanning status
  get status => _status;

  /// Returns difference between scanning start and finish in milliseconds.
  /// If scanning is still in progress then returns difference between scanning start and current time.
  /// If start time is undefined return -1
  get elapsed {
    if (_elapsed != null) {
      return _elapsed;
    } else if (_startTime == null) {
      return -1;
    } else {
      return DateTime.now().difference(_startTime).inMilliseconds;
    }
  }

  set elapsed(value) {
    _elapsed = value;
  }
}
