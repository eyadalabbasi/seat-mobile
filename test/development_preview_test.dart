import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seat_mobile/app/seat_app.dart';
import 'package:seat_mobile/core/config/app_config.dart';
import 'package:seat_mobile/core/fixtures/fixture_store.dart';
import 'package:seat_mobile/features/auth/data/auth_repository.dart';
import 'package:seat_mobile/features/discovery/data/discovery_repository.dart';
import 'package:seat_mobile/features/discovery/presentation/discovery_screens.dart';
import 'package:seat_mobile/features/reservations/data/reservation_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:seat_mobile/l10n/app_localizations.dart';

final fixtureConfig = AppConfig(
  environment: AppEnvironment.dev,
  apiBaseUrl: Uri.parse('http://fixture.invalid'),
  enableFixtures: true,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('fixtures activate only for dev', () {
    expect(fixtureConfig.useFixtures, isTrue);
    expect(
      AppConfig(
        environment: AppEnvironment.staging,
        apiBaseUrl: Uri.parse('https://staging.example'),
        enableFixtures: true,
      ).useFixtures,
      isFalse,
    );
    expect(
      AppConfig(
        environment: AppEnvironment.prod,
        apiBaseUrl: Uri.parse('https://api.example'),
        enableFixtures: true,
      ).useFixtures,
      isFalse,
    );
  });

  test(
    'provider switching is centralized and production remains API backed',
    () {
      final fixtureContainer = ProviderContainer(
        overrides: [appConfigProvider.overrideWithValue(fixtureConfig)],
      );
      addTearDown(fixtureContainer.dispose);
      expect(
        fixtureContainer.read(authRepositoryProvider),
        isA<FixtureAuthRepository>(),
      );
      expect(
        fixtureContainer.read(discoveryRepositoryProvider),
        isA<FixtureDiscoveryRepository>(),
      );
      expect(
        fixtureContainer.read(reservationRepositoryProvider),
        isA<FixtureReservationRepository>(),
      );
      final production = ProviderContainer(
        overrides: [
          appConfigProvider.overrideWithValue(
            AppConfig(
              environment: AppEnvironment.prod,
              apiBaseUrl: Uri.parse('https://api.example'),
              enableFixtures: false,
            ),
          ),
        ],
      );
      addTearDown(production.dispose);
      expect(production.read(authRepositoryProvider), isA<ApiAuthRepository>());
      expect(
        production.read(discoveryRepositoryProvider),
        isA<ApiDiscoveryRepository>(),
      );
      expect(
        production.read(reservationRepositoryProvider),
        isA<ApiReservationRepository>(),
      );
    },
  );

  test('fixture login accepts only documented preview credentials', () async {
    final store = FixtureStore();
    final repository = FixtureAuthRepository(store);
    final challenge = await repository.requestOtp(
      FixtureAuthRepository.previewPhone,
    );
    await repository.verifyOtp(challenge, FixtureAuthRepository.previewOtp);
    expect(await repository.restore(), isTrue);
    expect(
      () => repository.requestOtp('+97339999999'),
      throwsA(isA<Exception>()),
    );
  });

  testWidgets('language selection progresses to login and persists', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appConfigProvider.overrideWithValue(fixtureConfig)],
        child: const SeatApp(),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('Choose your language'), findsOneWidget);
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.text('Enter your mobile number'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('language_selected'), isTrue);
    expect(prefs.getString('locale'), 'en');
  });

  testWidgets('Arabic selection produces RTL login', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appConfigProvider.overrideWithValue(fixtureConfig)],
        child: const SeatApp(),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await tester.tap(find.text('العربية'));
    await tester.pumpAndSettle();
    expect(find.text('أدخل رقم هاتفك'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text('أدخل رقم هاتفك'))),
      TextDirection.rtl,
    );
  });

  testWidgets('fixture Home renders Bahrain restaurant data', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appConfigProvider.overrideWithValue(fixtureConfig)],
        child: const MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(body: HomeScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Saffron House'), findsOneWidget);
    expect(find.textContaining('Manama'), findsOneWidget);
  });
}
