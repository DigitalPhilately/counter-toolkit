import 'package:flutter_test/flutter_test.dart';

import 'package:counter_toolkit/main.dart';

void main() {
  testWidgets('renders the Counter Toolkit dashboard', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CounterToolkitApp());

    expect(find.text('Counter Toolkit'), findsOneWidget);
    expect(find.text('Track & Trace'), findsOneWidget);
    expect(find.text('What the app should help with first'), findsOneWidget);
  });
}
