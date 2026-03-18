import 'package:counter_toolkit/features/tracking/data/mock_tracking_service.dart';
import 'package:counter_toolkit/features/tracking/domain/tracking_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = MockTrackingService();

  test('normalises references and returns a mock result', () async {
    final outcome = await service.lookup('ab 123456789 gb');

    expect(outcome.found, isTrue);
    expect(outcome.item?.reference, 'AB123456789GB');
    expect(outcome.item?.status, TrackingStage.delivered);
  });

  test('returns helpful guidance for unknown S10-style references', () async {
    final outcome = await service.lookup('ZZ123456789GB');

    expect(outcome.found, isFalse);
    expect(outcome.message, contains('S10-style postal reference'));
  });
}
