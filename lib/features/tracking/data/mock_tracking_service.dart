import 'package:counter_toolkit/features/tracking/domain/tracking_models.dart';
import 'package:counter_toolkit/features/tracking/domain/tracking_service.dart';

class MockTrackingService extends TrackingService {
  const MockTrackingService();

  static const List<String> _sampleReferences = [
    'AB123456789GB',
    'CD987654321GB',
    'LX246813579GB',
  ];

  static final Map<String, TrackingItem> _fixtures = {
    'AB123456789GB': TrackingItem(
      reference: 'AB123456789GB',
      network: TrackingNetwork.royalMail,
      serviceName: 'Royal Mail Tracked 48',
      status: TrackingStage.delivered,
      summary: 'Delivered and marked as handed to the customer.',
      destination: 'London SW1A',
      latestLocation: 'Westminster Delivery Office',
      lastUpdated: DateTime(2026, 3, 18, 9, 42),
      deliveryEstimate: DateTime(2026, 3, 18, 18),
      requiresSignature: false,
      notices: ['Mock tracking response for UI development.'],
      events: [
        TrackingEvent(
          timestamp: DateTime(2026, 3, 18, 9, 42),
          title: 'Delivered',
          detail: 'Item delivered on the planned round.',
          location: 'Westminster Delivery Office',
          stage: TrackingStage.delivered,
        ),
        TrackingEvent(
          timestamp: DateTime(2026, 3, 18, 7, 18),
          title: 'Out for delivery',
          detail: 'Driver started the route with the parcel.',
          location: 'Westminster Delivery Office',
          stage: TrackingStage.outForDelivery,
        ),
        TrackingEvent(
          timestamp: DateTime(2026, 3, 17, 22, 11),
          title: 'Arrived at delivery office',
          detail: 'Sorted to the local unit ready for the next round.',
          location: 'Westminster Delivery Office',
          stage: TrackingStage.inTransit,
        ),
        TrackingEvent(
          timestamp: DateTime(2026, 3, 17, 15, 06),
          title: 'Accepted',
          detail: 'Sender handed the item over at the counter.',
          location: 'Birmingham Mail Centre',
          stage: TrackingStage.accepted,
        ),
      ],
    ),
    'CD987654321GB': TrackingItem(
      reference: 'CD987654321GB',
      network: TrackingNetwork.parcelForce,
      serviceName: 'Parcelforce Express 24',
      status: TrackingStage.inTransit,
      summary: 'In transit between processing centres.',
      destination: 'Bristol BS1',
      latestLocation: 'South West Hub',
      lastUpdated: DateTime(2026, 3, 18, 11, 08),
      deliveryEstimate: DateTime(2026, 3, 19, 17),
      requiresSignature: true,
      notices: [
        'Signature expected on delivery.',
        'Mock provider used until a live API is connected.',
      ],
      events: [
        TrackingEvent(
          timestamp: DateTime(2026, 3, 18, 11, 08),
          title: 'Processed through hub',
          detail: 'Item routed to the final delivery region.',
          location: 'South West Hub',
          stage: TrackingStage.inTransit,
        ),
        TrackingEvent(
          timestamp: DateTime(2026, 3, 18, 6, 54),
          title: 'Departed national hub',
          detail: 'Loaded for onward trunk movement.',
          location: 'National Hub',
          stage: TrackingStage.inTransit,
        ),
        TrackingEvent(
          timestamp: DateTime(2026, 3, 17, 18, 17),
          title: 'Collected from sender',
          detail: 'Driver scanned parcel into the network.',
          location: 'Leicester',
          stage: TrackingStage.accepted,
        ),
      ],
    ),
    'LX246813579GB': TrackingItem(
      reference: 'LX246813579GB',
      network: TrackingNetwork.upu,
      serviceName: 'International tracked packet',
      status: TrackingStage.held,
      summary: 'Held for customs review before final release.',
      destination: 'London Heathrow inward office',
      latestLocation: 'International processing centre',
      lastUpdated: DateTime(2026, 3, 18, 13, 16),
      deliveryEstimate: DateTime(2026, 3, 21, 18),
      isInternational: true,
      notices: [
        'S10-style reference suitable for UPU-style integrations.',
        'Customer may need to wait for customs clearance updates.',
      ],
      events: [
        TrackingEvent(
          timestamp: DateTime(2026, 3, 18, 13, 16),
          title: 'Held for customs review',
          detail: 'Awaiting border processing outcome.',
          location: 'International processing centre',
          stage: TrackingStage.held,
        ),
        TrackingEvent(
          timestamp: DateTime(2026, 3, 18, 3, 40),
          title: 'Arrived in destination country',
          detail: 'Inbound scan recorded at the arrival office.',
          location: 'London Heathrow inward office',
          stage: TrackingStage.inTransit,
        ),
        TrackingEvent(
          timestamp: DateTime(2026, 3, 16, 21, 12),
          title: 'Dispatched from origin exchange office',
          detail: 'Item exported from the origin postal network.',
          location: 'Paris exchange office',
          stage: TrackingStage.accepted,
        ),
      ],
    ),
  };

  @override
  List<String> get sampleReferences => List.unmodifiable(_sampleReferences);

  @override
  Future<TrackingLookupOutcome> lookup(String reference) async {
    final normalised = normaliseTrackingReference(reference);

    await Future<void>.delayed(const Duration(milliseconds: 650));

    final item = _fixtures[normalised];
    if (item != null) {
      return TrackingLookupOutcome(
        searchedReference: normalised,
        item: item,
        message:
            'Mock journey loaded. Replace this service with a backend adapter when provider credentials are ready.',
        fromMockService: true,
      );
    }

    final message = looksLikeS10Reference(normalised)
        ? 'This looks like an S10-style postal reference. It is a good candidate for a future UPU or operator-backed lookup.'
        : 'No mock journey is stored for this number yet. The UI is ready for a live backend next.';

    return TrackingLookupOutcome(
      searchedReference: normalised,
      message: message,
      fromMockService: true,
    );
  }
}
