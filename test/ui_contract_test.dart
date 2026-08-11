import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seat_mobile/core/models/models.dart';
import 'package:seat_mobile/core/widgets/seat_widgets.dart';
import 'package:seat_mobile/l10n/app_localizations.dart';

Widget localized(Widget child, {Locale locale = const Locale('en')}) =>
    MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('waiting state never says pending reservation or confirmed', (
    tester,
  ) async {
    await tester.pumpWidget(
      localized(const StatusChip(status: ReservationStatus.requested)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Waiting for restaurant'), findsOneWidget);
    expect(find.textContaining('Pending Reservation'), findsNothing);
    expect(find.text('Confirmed'), findsNothing);
  });

  testWidgets('Arabic status is translated and rendered RTL', (tester) async {
    await tester.pumpWidget(
      localized(
        const StatusChip(status: ReservationStatus.alternativeProposed),
        locale: const Locale('ar'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('تم اقتراح وقت جديد'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.byType(StatusChip))),
      TextDirection.rtl,
    );
  });

  testWidgets('status communicates with text and icon', (tester) async {
    await tester.pumpWidget(
      localized(const StatusChip(status: ReservationStatus.confirmed)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Confirmed'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });
}
