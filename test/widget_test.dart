import 'package:counter_toolkit/app/counter_toolkit_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('opens track and trace and shows a sample result', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CounterToolkitApp());

    expect(find.text('Open Track & Trace'), findsOneWidget);
    expect(find.text('Open Best Fit Stamps'), findsOneWidget);

    await tester.ensureVisible(find.text('Open Track & Trace'));
    await tester.tap(find.text('Open Track & Trace'));
    await tester.pumpAndSettle();

    expect(find.text('Track & Trace'), findsWidgets);
    expect(find.text('Search by tracking reference'), findsOneWidget);
    expect(find.text('Auto route'), findsOneWidget);

    await tester.ensureVisible(find.text('Look up'));
    await tester.tap(find.text('Look up'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('Delivered'), findsWidgets);
    expect(find.text('Tracking timeline'), findsOneWidget);
    expect(find.textContaining('Resolved: Royal Mail'), findsOneWidget);
  });

  testWidgets(
    'best fit stamps keeps setup separate from the main result view',
    (WidgetTester tester) async {
      await tester.pumpWidget(const CounterToolkitApp());

      await tester.ensureVisible(find.text('Open Best Fit Stamps'));
      await tester.tap(find.text('Open Best Fit Stamps'));
      await tester.pumpAndSettle();

      expect(find.text('Best Fit Stamps'), findsOneWidget);
      expect(find.textContaining('Best fit for £10.25'), findsOneWidget);
      expect(find.text('Prefer NVI'), findsNothing);
      expect(find.text('No high tariff'), findsNothing);

      await tester.tap(find.text('Pence'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('target-amount-field')),
        '1025',
      );
      await tester.tap(find.text('Recalculate'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Best fit for £10.25'), findsOneWidget);

      await tester.tap(find.text('Setup & stock'));
      await tester.pumpAndSettle();

      expect(find.text('Prefer NVI'), findsOneWidget);
      expect(find.text('No high tariff'), findsOneWidget);
      expect(find.text('No stamp values marked out of stock.'), findsOneWidget);

      await tester.ensureVisible(find.byKey(const ValueKey('stock-tile-340')));
      await tester.tap(find.byKey(const ValueKey('stock-tile-340')));
      await tester.pumpAndSettle();

      expect(find.text('1 value marked out of stock.'), findsOneWidget);
    },
  );
}
