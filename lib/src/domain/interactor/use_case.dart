import '../entities/report.dart';

abstract class UseCase {
  Future<Report> get report;

  Future<Report> scan();

  void cancel();
}
