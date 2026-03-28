import 'package:counter_toolkit/features/stamps/data/default_stamp_catalog.dart';
import 'package:counter_toolkit/features/stamps/domain/best_fit_stamp_solver.dart';
import 'package:counter_toolkit/features/stamps/domain/stamp_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const solver = BestFitStampSolver(defaultStampCatalog);

  test('returns an exact recommendation for the default counter settings', () {
    final result = solver.calculate(
      targetValuePence: 1025,
      settings: const StampCalculatorSettings(),
    );

    expect(result.hasSolution, isTrue);
    expect(result.recommended?.totalValuePence, 1025);
    expect(result.recommended?.signature, '340x3|5x1');
    expect(result.recommended?.distinctValueCount, 2);
  });

  test('prefers a shorter pick list over fewer stamp values', () {
    final result = solver.calculate(
      targetValuePence: 25,
      settings: const StampCalculatorSettings(),
    );

    expect(result.hasSolution, isTrue);
    expect(result.recommended?.signature, '20x1|5x1');
    expect(result.recommended?.totalStampCount, 2);
  });

  test('high tariff toggle excludes 350 and 430 while keeping 340', () {
    final result = solver.calculate(
      targetValuePence: 1025,
      settings: const StampCalculatorSettings(excludeHighTariff: true),
    );

    final availableValues = result.availableStamps
        .map((stamp) => stamp.valuePence)
        .toSet();

    expect(availableValues.contains(430), isFalse);
    expect(availableValues.contains(350), isFalse);
    expect(availableValues.contains(340), isTrue);
  });

  test('dynamic exclusions trigger a different exact recommendation', () {
    final result = solver.calculate(
      targetValuePence: 1025,
      settings: const StampCalculatorSettings(excludedValues: {340}),
    );

    expect(result.hasSolution, isTrue);
    expect(result.recommended?.totalValuePence, 1025);
    expect(result.recommended?.signature, '315x1|170x3|100x2');
    expect(result.recommended?.totalStampCount, 6);
    expect(result.recommended?.distinctValueCount, 3);
  });
}
