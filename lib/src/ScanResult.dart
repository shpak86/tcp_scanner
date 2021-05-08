import 'dart:convert';

/// Scanning statuses
enum ScanStatuses { unknown, scanning, finished }

/// Scan result contains data of prepared, current and finished scan.
class ScanResult {
  static final String keyHost = 'host';
  static final String keyPorts = 'ports';
  static final String keyScanned = 'scanned';
  static final String keyOpen = 'open';
  static final String keyClosed = 'closed';
  static final String keyElapsed = 'elapsed';
  static final String keyStatus = 'status';

  /// Host
  String? host;

  /// All testing ports
  List<int> ports = [];

  /// Open ports
  List<int> open = [];

  /// Closed ports
  List<int> closed = [];

  /// Ports which was scanned. This field is modifies when scan is in progress.
  List<int> scanned = [];

  /// Elapsed time. It can be null if scanning is in progress.
  int? _elapsed;

  /// Time when status changed to scanning
  DateTime? _startTime;

  /// Time when status changed to finished
  DateTime? _finishTime;

  /// Current status
  ScanStatuses _status = ScanStatuses.unknown;

  /// Main constructor
  ScanResult({String? host, List<int> ports = const [], List<int> open = const [], List<int> closed = const [], List<int> scanned = const [], ScanStatuses status = ScanStatuses.unknown}) {
    this.host = host;
    this.ports.addAll(ports);
    this.open.addAll(open);
    this.closed.addAll(closed);
    this.scanned.addAll(scanned);
    _status = status;
    if (status != ScanStatuses.finished) _startTime = DateTime.now();
  }

  /// Creation object from JSON
  ScanResult.fromJson(String json) {
    fromJson(json);
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson() {
    var statusString = 'unknown';
    if (_status == ScanStatuses.scanning) {
      statusString = 'scanning';
    } else if (_status == ScanStatuses.finished) {
      statusString = 'finished';
    }
    return {keyHost: host, keyPorts: ports, keyScanned: scanned, keyOpen: open, keyClosed: closed, keyElapsed: elapsed, keyStatus: statusString};
  }

  /// Deserialize from JSON
  void fromJson(String json) {
    Map<String, dynamic> map = jsonDecode(json);
    if (map.containsKey(keyHost)) host = map[keyHost].toString();
    if (map.containsKey(keyPorts)) ports = List<int>.from(map[keyPorts]);
    if (map.containsKey(keyScanned)) scanned = List<int>.from(map[keyScanned]);
    if (map.containsKey(keyOpen)) open = List<int>.from(map[keyOpen]);
    if (map.containsKey(keyClosed)) closed = List<int>.from(map[keyClosed]);
    if (map.containsKey(keyElapsed)) _elapsed = map[keyElapsed];
    if (map.containsKey(keyStatus)) {
      if (map[keyStatus] == 'finished') {
        _status = ScanStatuses.finished;
      } else if (map[keyStatus] == 'scanning') {
        _status = ScanStatuses.scanning;
      } else {
        _status = ScanStatuses.unknown;
      }
    }
  }

  /// Add single port
  void addPort(int port) => ports.add(port);

  /// Add open port
  void addOpen(int port) => open.add(port);

  /// Add closed port
  void addClosed(int port) => closed.add(port);

  /// Add scanned port
  void addScanned(int port) => scanned.add(port);

  /// Sets status, and modifies startTime and finishTime. If status is finished then modifies _elapsedTime.
  set status(value) {
    _status = value;
    if (value == ScanStatuses.scanning) {
      _startTime = DateTime.now();
    } else if (value == ScanStatuses.finished) {
      if (_startTime == null) {
        _elapsed = -1;
      } else {
        _finishTime = DateTime.now();
        _elapsed = _finishTime!.difference(_startTime!).inMilliseconds;
      }
    }
  }

  /// Returns current scanning status
  ScanStatuses get status => _status;

  /// Returns elapsed scan time in milliseconds.
  /// If scanning is still in progress then returns difference between scan start and current time.
  /// If the start time is undefined return -1
  int get elapsed {
    if (_elapsed != null) {
      return _elapsed!;
    } else if (_startTime == null || _finishTime == null) {
      return -1;
    } else {
      return DateTime.now().difference(_startTime!).inMilliseconds;
    }
  }

  set elapsed(value) {
    _elapsed = value;
  }
}
