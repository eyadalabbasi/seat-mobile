import 'package:flutter_test/flutter_test.dart';
import 'package:seat_mobile/core/api/api_client.dart';
import 'package:seat_mobile/core/config/app_config.dart';
import 'dart:io';

void main() {
  test('flavor enum contains dev staging and prod', () {
    expect(AppEnvironment.values.map((value) => value.name), [
      'dev',
      'staging',
      'prod',
    ]);
  });
  test('structured API failures preserve business code', () {
    const failure = ApiFailure(
      'ALTERNATIVE_NOT_AVAILABLE',
      'Unavailable',
      statusCode: 409,
    );
    expect(failure.code, 'ALTERNATIVE_NOT_AVAILABLE');
    expect(failure.statusCode, 409);
    expect(failure.isOffline, isFalse);
  });
  test('network failure is recognized as offline', () {
    expect(
      const ApiFailure('NETWORK_UNAVAILABLE', 'offline').isOffline,
      isTrue,
    );
  });
  test('list response envelopes retain their data collection', () {
    final response = unwrapResponseMap({
      'data': <Object?>[
        {'id': 'restaurant-1'},
      ],
      'pagination': {'page': 1},
    });

    expect(unwrapItems(response), [
      {'id': 'restaurant-1'},
    ]);
  });
  test('release manifest permits staging HTTPS traffic', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    expect(
      manifest,
      contains('android.permission.INTERNET'),
      reason: 'Release builds must be allowed to reach the staging API.',
    );
  });
}
