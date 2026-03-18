enum TrackingStage {
  accepted,
  inTransit,
  outForDelivery,
  delivered,
  held,
  issue,
}

enum TrackingNetwork { royalMail, upu, parcelForce }

enum TrackingLookupMode { auto, royalMail, parcelForce, upu }

enum TrackingIntegrationReadiness { demoReady, backendNext, accessControlled }

class TrackingProviderGuide {
  const TrackingProviderGuide({
    required this.mode,
    required this.title,
    required this.summary,
    required this.focus,
    required this.readiness,
  });

  final TrackingLookupMode mode;
  final String title;
  final String summary;
  final String focus;
  final TrackingIntegrationReadiness readiness;
}

class TrackingLookupRequest {
  const TrackingLookupRequest({
    required this.reference,
    this.mode = TrackingLookupMode.auto,
  });

  final String reference;
  final TrackingLookupMode mode;
}

class TrackingLookupRoute {
  const TrackingLookupRoute({
    required this.requestedMode,
    required this.resolvedMode,
    required this.reason,
    required this.readiness,
  });

  final TrackingLookupMode requestedMode;
  final TrackingLookupMode resolvedMode;
  final String reason;
  final TrackingIntegrationReadiness readiness;

  bool get usedAutoRouting => requestedMode == TrackingLookupMode.auto;
}

class TrackingEvent {
  const TrackingEvent({
    required this.timestamp,
    required this.title,
    required this.detail,
    required this.location,
    required this.stage,
  });

  final DateTime timestamp;
  final String title;
  final String detail;
  final String location;
  final TrackingStage stage;
}

class TrackingItem {
  const TrackingItem({
    required this.reference,
    required this.network,
    required this.serviceName,
    required this.status,
    required this.summary,
    required this.destination,
    required this.latestLocation,
    required this.lastUpdated,
    required this.events,
    this.deliveryEstimate,
    this.requiresSignature = false,
    this.isInternational = false,
    this.notices = const [],
  });

  final String reference;
  final TrackingNetwork network;
  final String serviceName;
  final TrackingStage status;
  final String summary;
  final String destination;
  final String latestLocation;
  final DateTime lastUpdated;
  final DateTime? deliveryEstimate;
  final bool requiresSignature;
  final bool isInternational;
  final List<String> notices;
  final List<TrackingEvent> events;
}

class TrackingLookupOutcome {
  const TrackingLookupOutcome({
    required this.searchedReference,
    required this.message,
    required this.fromMockService,
    required this.route,
    this.item,
  });

  final String searchedReference;
  final TrackingItem? item;
  final String message;
  final bool fromMockService;
  final TrackingLookupRoute route;

  bool get found => item != null;
}

const List<TrackingLookupMode> trackingLookupModes = [
  TrackingLookupMode.auto,
  TrackingLookupMode.royalMail,
  TrackingLookupMode.parcelForce,
  TrackingLookupMode.upu,
];

const List<TrackingProviderGuide> defaultTrackingProviderGuides = [
  TrackingProviderGuide(
    mode: TrackingLookupMode.royalMail,
    title: 'Royal Mail',
    summary: 'Best first live adapter for UK-focused tracked items.',
    focus: 'Business onboarding plus a backend-owned server integration.',
    readiness: TrackingIntegrationReadiness.backendNext,
  ),
  TrackingProviderGuide(
    mode: TrackingLookupMode.parcelForce,
    title: 'Parcelforce',
    summary:
        'Useful when counter staff need a courier-style route in the same toolkit.',
    focus: 'Keep the same app contract and swap only the backend adapter.',
    readiness: TrackingIntegrationReadiness.backendNext,
  ),
  TrackingProviderGuide(
    mode: TrackingLookupMode.upu,
    title: 'UPU / Postal Network',
    summary:
        'Strong fit for international S10-style references and postal-network events.',
    focus:
        'Treat access as controlled and keep credentials and mapping on your backend.',
    readiness: TrackingIntegrationReadiness.accessControlled,
  ),
];

String normaliseTrackingReference(String raw) {
  return raw.toUpperCase().replaceAll(RegExp(r'[\s-]+'), '');
}

String? validateTrackingReference(String raw) {
  final normalised = normaliseTrackingReference(raw);

  if (normalised.isEmpty) {
    return 'Enter a tracking number.';
  }
  if (normalised.length < 8) {
    return 'Tracking numbers are usually at least 8 characters.';
  }
  if (normalised.length > 24) {
    return 'This looks too long for a standard postal tracking number.';
  }
  if (!RegExp(r'^[A-Z0-9]+$').hasMatch(normalised)) {
    return 'Use letters, numbers, spaces, or hyphens only.';
  }

  return null;
}

bool looksLikeS10Reference(String value) {
  return RegExp(r'^[A-Z]{2}\d{9}[A-Z]{2}$').hasMatch(value);
}

TrackingLookupMode trackingLookupModeForNetwork(TrackingNetwork network) {
  switch (network) {
    case TrackingNetwork.royalMail:
      return TrackingLookupMode.royalMail;
    case TrackingNetwork.upu:
      return TrackingLookupMode.upu;
    case TrackingNetwork.parcelForce:
      return TrackingLookupMode.parcelForce;
  }
}

String trackingLookupModeLabel(TrackingLookupMode mode) {
  switch (mode) {
    case TrackingLookupMode.auto:
      return 'Auto route';
    case TrackingLookupMode.royalMail:
      return 'Royal Mail';
    case TrackingLookupMode.parcelForce:
      return 'Parcelforce';
    case TrackingLookupMode.upu:
      return 'UPU';
  }
}

String trackingLookupModeDescription(TrackingLookupMode mode) {
  switch (mode) {
    case TrackingLookupMode.auto:
      return 'Let the app choose the most likely provider path.';
    case TrackingLookupMode.royalMail:
      return 'Aim the lookup at Royal Mail-style tracked items.';
    case TrackingLookupMode.parcelForce:
      return 'Use a Parcelforce-style route for courier handling.';
    case TrackingLookupMode.upu:
      return 'Send international postal references toward a UPU-style flow.';
  }
}

TrackingIntegrationReadiness trackingIntegrationReadinessForMode(
  TrackingLookupMode mode,
) {
  switch (mode) {
    case TrackingLookupMode.auto:
      return TrackingIntegrationReadiness.demoReady;
    case TrackingLookupMode.royalMail:
    case TrackingLookupMode.parcelForce:
      return TrackingIntegrationReadiness.backendNext;
    case TrackingLookupMode.upu:
      return TrackingIntegrationReadiness.accessControlled;
  }
}

String trackingIntegrationReadinessLabel(
  TrackingIntegrationReadiness readiness,
) {
  switch (readiness) {
    case TrackingIntegrationReadiness.demoReady:
      return 'Demo ready';
    case TrackingIntegrationReadiness.backendNext:
      return 'Backend next';
    case TrackingIntegrationReadiness.accessControlled:
      return 'Approval needed';
  }
}

String trackingIntegrationReadinessDescription(
  TrackingIntegrationReadiness readiness,
) {
  switch (readiness) {
    case TrackingIntegrationReadiness.demoReady:
      return 'Safe to prototype in-app while the backend catches up.';
    case TrackingIntegrationReadiness.backendNext:
      return 'Best wired through your own backend before it ships.';
    case TrackingIntegrationReadiness.accessControlled:
      return 'Treat onboarding and credentials as a separate workstream.';
  }
}
