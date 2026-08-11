import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class AnalyticsClient {
  Future<void> track(
    String event, [
    Map<String, Object?> properties = const {},
  ]);
}

class NoopAnalyticsClient implements AnalyticsClient {
  @override
  Future<void> track(
    String event, [
    Map<String, Object?> properties = const {},
  ]) async {}
}

final analyticsProvider = Provider<AnalyticsClient>(
  (ref) => NoopAnalyticsClient(),
);
