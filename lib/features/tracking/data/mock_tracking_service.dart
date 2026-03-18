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
  List<TrackingLookupMode> get supportedModes =>
      List.unmodifiable(trackingLookupModes);

  @override
  List<TrackingProviderGuide> get providerGuides =>
      List.unmodifiable(defaultTrackingProviderGuides);

  @override
  Future<TrackingLookupOutcome> lookup(TrackingLookupRequest request) async {
    final normalised = normaliseTrackingReference(request.reference);

    await Future<void>.delayed(const Duration(milliseconds: 650));

    final fixture = _fixtures[normalised];
    final route = _resolveRoute(normalised, request.mode, fixture: fixture);

    if (fixture != null) {
      final fixtureMode = trackingLookupModeForNetwork(fixture.network);

      if (request.mode != TrackingLookupMode.auto &&
          request.mode != fixtureMode) {
        return TrackingLookupOutcome(
          searchedReference: normalised,
          route: route,
          message:
              'This reference is stored in the demo set, but it belongs to ${trackingLookupModeLabel(fixtureMode)}. Try Auto route or switch provider.',
          fromMockService: true,
        );
      }

      return TrackingLookupOutcome(
        searchedReference: normalised,
        route: TrackingLookupRoute(
          requestedMode: request.mode,
          resolvedMode: fixtureMode,
          reason: request.mode == TrackingLookupMode.auto
              ? 'Auto route matched a stored ${trackingLookupModeLabel(fixtureMode)} demo journey.'
              : '${trackingLookupModeLabel(fixtureMode)} route selected explicitly for this lookup.',
          readiness: trackingIntegrationReadinessForMode(fixtureMode),
        ),
        item: fixture,
        message: _successMessageForMode(fixtureMode),
        fromMockService: true,
      );
    }

    return TrackingLookupOutcome(
      searchedReference: normalised,
      route: route,
      message: _notFoundMessageForRoute(normalised, route),
      fromMockService: true,
    );
  }

  TrackingLookupRoute _resolveRoute(
    String reference,
    TrackingLookupMode requestedMode, {
    TrackingItem? fixture,
  }) {
    if (fixture != null) {
      final fixtureMode = trackingLookupModeForNetwork(fixture.network);

      if (requestedMode == TrackingLookupMode.auto) {
        return TrackingLookupRoute(
          requestedMode: requestedMode,
          resolvedMode: fixtureMode,
          reason:
              'Auto route matched the demo journey already stored for this reference.',
          readiness: trackingIntegrationReadinessForMode(fixtureMode),
        );
      }

      return TrackingLookupRoute(
        requestedMode: requestedMode,
        resolvedMode: requestedMode,
        reason:
            '${trackingLookupModeLabel(requestedMode)} route selected by the clerk for this lookup.',
        readiness: trackingIntegrationReadinessForMode(requestedMode),
      );
    }

    if (requestedMode != TrackingLookupMode.auto) {
      return TrackingLookupRoute(
        requestedMode: requestedMode,
        resolvedMode: requestedMode,
        reason:
            '${trackingLookupModeLabel(requestedMode)} route selected by the clerk for this lookup.',
        readiness: trackingIntegrationReadinessForMode(requestedMode),
      );
    }

    final inferredMode = _inferModeFromReference(reference);
    return TrackingLookupRoute(
      requestedMode: requestedMode,
      resolvedMode: inferredMode,
      reason: _autoRouteReason(reference, inferredMode),
      readiness: trackingIntegrationReadinessForMode(inferredMode),
    );
  }

  TrackingLookupMode _inferModeFromReference(String reference) {
    if (looksLikeS10Reference(reference)) {
      return TrackingLookupMode.upu;
    }
    if (reference.startsWith('CD') || reference.startsWith('PF')) {
      return TrackingLookupMode.parcelForce;
    }
    return TrackingLookupMode.royalMail;
  }

  String _autoRouteReason(String reference, TrackingLookupMode inferredMode) {
    switch (inferredMode) {
      case TrackingLookupMode.auto:
        return 'Auto route is waiting for more information.';
      case TrackingLookupMode.royalMail:
        return 'No stronger pattern matched, so the lookup falls back to a Royal Mail-style route first.';
      case TrackingLookupMode.parcelForce:
        return 'The reference shape matches the Parcelforce-style demo path used in this prototype.';
      case TrackingLookupMode.upu:
        return looksLikeS10Reference(reference)
            ? 'This looks like an S10-style postal reference, so auto route points it toward the international postal path.'
            : 'Auto route chose the UPU-style path for an international-style reference.';
    }
  }

  String _successMessageForMode(TrackingLookupMode mode) {
    switch (mode) {
      case TrackingLookupMode.auto:
        return 'Mock journey loaded.';
      case TrackingLookupMode.royalMail:
        return 'Royal Mail-style demo journey loaded. Replace this service with a backend adapter when server credentials are ready.';
      case TrackingLookupMode.parcelForce:
        return 'Parcelforce-style demo journey loaded. The UI is ready for a provider-specific backend adapter next.';
      case TrackingLookupMode.upu:
        return 'UPU-style demo journey loaded. Keep the live integration behind your backend once access is approved.';
    }
  }

  String _notFoundMessageForRoute(String reference, TrackingLookupRoute route) {
    switch (route.resolvedMode) {
      case TrackingLookupMode.auto:
        return 'The route has not been resolved yet.';
      case TrackingLookupMode.royalMail:
        return 'No mock Royal Mail journey is stored for this number yet. The screen is ready for a backend-backed lookup next.';
      case TrackingLookupMode.parcelForce:
        return 'No mock Parcelforce journey is stored for this number yet. Keep the same UI and swap in a provider adapter later.';
      case TrackingLookupMode.upu:
        return looksLikeS10Reference(reference)
            ? 'This looks like an S10-style postal reference. It is a strong candidate for a future UPU or operator-backed lookup.'
            : 'No mock international postal journey is stored for this number yet.';
    }
  }
}
