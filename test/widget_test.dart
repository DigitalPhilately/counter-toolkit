import 'package:counter_toolkit/app/counter_toolkit_app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('opens track and trace and shows a sample result', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CounterToolkitApp());

    expect(find.text('Open Track & Trace'), findsOneWidget);

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
}
