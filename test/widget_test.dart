import 'package:counter_toolkit/app/counter_toolkit_app.dart';
import 'package:counter_toolkit/features/stamps/presentation/stamp_tile.dart';
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

  testWidgets('opens best fit stamps and marks a tile unavailable', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CounterToolkitApp());

    await tester.ensureVisible(find.text('Open Best Fit Stamps'));
    await tester.tap(find.text('Open Best Fit Stamps'));
    await tester.pumpAndSettle();

    expect(find.text('Best Fit Stamps'), findsOneWidget);
    expect(find.textContaining('Best fit for £10.25'), findsOneWidget);

    final firstStampTile = find.byType(StampPickTile).first;
    await tester.ensureVisible(firstStampTile);
    await tester.tap(firstStampTile);
    await tester.pumpAndSettle();

    expect(find.text('Not available'), findsOneWidget);

    await tester.ensureVisible(find.text('Not available'));
    await tester.tap(find.text('Not available'));
    await tester.pumpAndSettle();

    expect(find.text('Excluded £3.40'), findsOneWidget);
  });
}
