import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seat_mobile/app/theme/seat_theme.dart';
import 'package:seat_mobile/core/formatting/seat_date_time.dart';
import 'package:seat_mobile/core/models/models.dart';
import 'package:seat_mobile/features/discovery/data/discovery_repository.dart';
import 'package:seat_mobile/features/discovery/presentation/discovery_screens.dart';
import 'package:seat_mobile/l10n/app_localizations.dart';

void main() {
  test('approved light-surface contrast tokens remain exact', () {
    expect(SeatColors.cream, const Color(0xFFF7F2E9));
    expect(SeatColors.surface, const Color(0xFFFFFCF7));
    expect(SeatColors.charcoal, const Color(0xFF24211F));
    expect(SeatColors.secondary, const Color(0xFF68615B));
  });

  test('restaurant parsing tolerates absent optional presentation fields', () {
    final restaurant = Restaurant.fromJson({'id': 'r1', 'name': 'Juniper'});
    expect(restaurant.name, 'Juniper');
    expect(restaurant.cuisine, isEmpty);
    expect(restaurant.area, isEmpty);
    expect(restaurant.imageUrl, isNull);
  });

  testWidgets('customer date formatting hides raw timestamp precision', (
    tester,
  ) async {
    final date = DateTime(2026, 8, 15, 19, 30, 52, 896);
    await tester.pumpWidget(
      _localized(
        'en',
        Builder(
          builder: (context) {
            return Text(SeatDateTime.dateTime(context, date));
          },
        ),
      ),
    );
    final text = tester.widget<Text>(find.byType(Text)).data!;
    expect(text, isNot(contains('2026-08')));
    expect(text, isNot(contains(':52')));
    expect(text, isNot(contains('896')));
  });

  testWidgets('Arabic formatting is RTL and keeps Latin digits', (
    tester,
  ) async {
    final date = DateTime(2026, 8, 15, 19, 30);
    await tester.pumpWidget(
      _localized(
        'ar',
        Builder(
          builder: (context) {
            return Text(SeatDateTime.dateTime(context, date));
          },
        ),
      ),
    );
    final element = tester.element(find.byType(Text));
    final text = tester.widget<Text>(find.byType(Text)).data!;
    expect(Directionality.of(element), TextDirection.rtl);
    expect(text, isNot(matches(RegExp('[٠-٩۰-۹]'))));
  });

  testWidgets('restaurant details tolerates branch without an identifier', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          discoveryRepositoryProvider.overrideWithValue(
            _NullableDetailRepository(),
          ),
        ],
        child: _localized(
          'en',
          const RestaurantDetailScreen(id: 'restaurant-optional'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Juniper Room'), findsWidgets);
    expect(tester.takeException(), isNull);
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });
}

Widget _localized(String language, Widget home) => MaterialApp(
  locale: Locale(language),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  theme: seatTheme(Locale(language)),
  home: home,
);

class _NullableDetailRepository implements DiscoveryRepository {
  @override
  Future<List<Map<String, Object?>>> branches(String id) async => [
    {'name': 'Seef branch', 'openingHours': '12:00–23:30'},
  ];

  @override
  Future<Restaurant> detail(String id) async => const Restaurant(
    id: 'restaurant-optional',
    name: 'Juniper Room',
    cuisine: 'Mediterranean',
    area: 'Seef',
  );

  @override
  Future<List<Restaurant>> list({
    int page = 1,
    String? area,
    double? latitude,
    double? longitude,
  }) async => [];

  @override
  Future<List<Restaurant>> search(String query, {String? area}) async => [];
}
