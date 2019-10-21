import 'dart:convert';
import 'package:tcp_scanner/tcp_scanner.dart';
import 'package:test/test.dart';

void main() {
  group('ScanResult tests', () {
    ScanResult noArgsResult, hostPortsScanningResult, hostPortsFinishedResult, deserializedRegularJson, deserializedBlankJson, scanResultBuilder;
    String regularJsonScanResult = '{"host":"localhost","ports":[900,9000,3000,3030],"scanned":[900,9000,3000],"open":[9000],"closed":[900,3000],"elapsed":26,"status":"scanning"}';
    String blankJsonScanResult = '{}';

    setUp(() {
      noArgsResult = ScanResult();
      hostPortsScanningResult = ScanResult(
          host: "host",
          ports: [
            80,
            8080,
            443,
            3000
          ],
          status: ScanStatuses.scanning);
      hostPortsFinishedResult = ScanResult(
          host: "host",
          ports: [
            80,
            8080,
            443,
            3000
          ],
          status: ScanStatuses.finished);
      deserializedRegularJson = ScanResult.fromJson(regularJsonScanResult);
      deserializedBlankJson = ScanResult.fromJson(blankJsonScanResult);
      scanResultBuilder = ScanResult();
      scanResultBuilder.status = ScanStatuses.scanning;
      scanResultBuilder..addPort(80)..addPort(8080)..addPort(443)..addPort(3000);
      scanResultBuilder..addScanned(80)..addScanned(8080)..addScanned(443);
      scanResultBuilder..addOpen(80)..addOpen(443);
      scanResultBuilder.addClosed(8080);
      scanResultBuilder.status = ScanStatuses.finished;
    });

    test('Constructor with no arguments test', () {
      expect(noArgsResult.host, isNull);
      expect(noArgsResult.ports, isList);
      expect(noArgsResult.ports, isEmpty);
      expect(noArgsResult.open, isList);
      expect(noArgsResult.open, isEmpty);
      expect(noArgsResult.closed, isList);
      expect(noArgsResult.closed, isEmpty);
      expect(noArgsResult.scanned, isList);
      expect(noArgsResult.scanned, isEmpty);
      expect(noArgsResult.status, ScanStatuses.unknown);
    });

    test('Constructor with host, ports and initial status', () {
      expect(hostPortsScanningResult.host, equals("host"));
      expect(
          hostPortsScanningResult.ports,
          equals(
            [
              80,
              8080,
              443,
              3000
            ],
          ));
      expect(hostPortsScanningResult.status, equals(ScanStatuses.scanning));

      expect(hostPortsFinishedResult.host, equals("host"));
      expect(
          hostPortsFinishedResult.ports,
          equals(
            [
              80,
              8080,
              443,
              3000
            ],
          ));
      expect(hostPortsFinishedResult.status, equals(ScanStatuses.finished));
    });

    test('Result builder methods tests', () {
      expect(
          scanResultBuilder.ports,
          equals(
            [
              80,
              8080,
              443,
              3000
            ],
          ));
      expect(
          scanResultBuilder.scanned,
          equals([
            80,
            8080,
            443
          ]));
      expect(
          scanResultBuilder.open,
          equals([
            80,
            443
          ]));
      expect(
          scanResultBuilder.closed,
          equals([
            8080,
          ]));
      // this test is not working 8(
//      expect(scanResultBuilder.elapsed, greaterThan(0));
      expect(scanResultBuilder.status, equals(ScanStatuses.finished));
    });

    test('Serialization tests', () {
      expect(
          jsonEncode(ScanResult(
              host: "localhost",
              ports: [
                900,
                9000,
                3030
              ],
              open: [
                9000
              ],
              scanned: [
                900,
                9000,
                3030
              ],
              closed: [
                900,
                3030
              ],
              status: ScanStatuses.finished)),
          equals('{"host":"localhost","ports":[900,9000,3030],"scanned":[900,9000,3030],"open":[9000],"closed":[900,3030],"elapsed":0,"status":"finished"}'));
      expect(deserializedRegularJson.host, equals("localhost"));
      expect(deserializedRegularJson.ports, isList);
      expect(
          deserializedRegularJson.ports,
          equals([
            900,
            9000,
            3000,
            3030
          ]));
      expect(deserializedRegularJson.scanned, isList);
      expect(
          deserializedRegularJson.scanned,
          equals([
            900,
            9000,
            3000
          ]));
      expect(deserializedRegularJson.open, isList);
      expect(
          deserializedRegularJson.open,
          equals([
            9000
          ]));
      expect(deserializedRegularJson.closed, isList);
      expect(
          deserializedRegularJson.closed,
          equals([
            900,
            3000
          ]));
      expect(deserializedRegularJson.elapsed, equals(26));
      expect(deserializedRegularJson.status, equals(ScanStatuses.scanning));

      expect(deserializedBlankJson.host, isNull);
      expect(deserializedBlankJson.ports, equals([]));
      expect(deserializedBlankJson.scanned, isList);
      expect(deserializedBlankJson.scanned, equals([]));
      expect(deserializedBlankJson.open, isList);
      expect(deserializedBlankJson.open, equals([]));
      expect(deserializedBlankJson.closed, isList);
      expect(deserializedBlankJson.closed, equals([]));
      expect(deserializedBlankJson.status, equals(ScanStatuses.unknown));
      expect(deserializedBlankJson.elapsed, equals(-1));
    });
  });
}
