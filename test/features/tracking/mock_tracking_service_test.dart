import 'package:counter_toolkit/features/tracking/data/mock_tracking_service.dart';
import 'package:counter_toolkit/features/tracking/domain/tracking_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = MockTrackingService();

  test('normalises references and returns a routed mock result', () async {
    final outcome = await service.lookup(
      const TrackingLookupRequest(reference: 'ab 123456789 gb'),
    );

    expect(outcome.found, isTrue);
    expect(outcome.item?.reference, 'AB123456789GB');
    expect(outcome.item?.status, TrackingStage.delivered);
    expect(outcome.route.usedAutoRouting, isTrue);
    expect(outcome.route.resolvedMode, TrackingLookupMode.royalMail);
  });

  test('returns helpful guidance for unknown S10-style references', () async {
    final outcome = await service.lookup(
      const TrackingLookupRequest(reference: 'ZZ123456789GB'),
    );

    expect(outcome.found, isFalse);
    expect(outcome.message, contains('S10-style postal reference'));
    expect(outcome.route.resolvedMode, TrackingLookupMode.upu);
  });

  test(
    'surfaces provider mismatch guidance when a clerk forces a route',
    () async {
      final outcome = await service.lookup(
        const TrackingLookupRequest(
          reference: 'AB123456789GB',
          mode: TrackingLookupMode.upu,
        ),
      );

      expect(outcome.found, isFalse);
      expect(outcome.message, contains('belongs to Royal Mail'));
      expect(outcome.route.resolvedMode, TrackingLookupMode.upu);
    },
  );
}
