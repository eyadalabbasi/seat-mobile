import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppEnvironment { dev, staging, prod }

class AppConfig {
  const AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.enableFixtures,
  });
  final AppEnvironment environment;
  final Uri apiBaseUrl;
  final bool enableFixtures;
  bool get useFixtures => environment == AppEnvironment.dev && enableFixtures;

  factory AppConfig.fromEnvironment() {
    const environmentValue = String.fromEnvironment(
      'APP_ENV',
      defaultValue: 'dev',
    );
    const url = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://10.0.2.2:3000',
    );
    const fixtures = bool.fromEnvironment('ENABLE_DEV_FIXTURES');
    final environment = AppEnvironment.values.byName(environmentValue);
    if (environment != AppEnvironment.dev && fixtures) {
      throw StateError('Development fixtures are forbidden outside dev.');
    }
    if (environment == AppEnvironment.prod && !url.startsWith('https://')) {
      throw StateError('Production API_BASE_URL must use HTTPS.');
    }
    return AppConfig(
      environment: environment,
      apiBaseUrl: Uri.parse(url),
      enableFixtures: fixtures,
    );
  }
}

final appConfigProvider = Provider<AppConfig>(
  (ref) => throw UnimplementedError('AppConfig override required'),
);
