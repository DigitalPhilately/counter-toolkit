enum TrackingStage {
  accepted,
  inTransit,
  outForDelivery,
  delivered,
  held,
  issue,
}

enum TrackingNetwork { royalMail, upu, parcelForce }

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
    this.item,
  });

  final String searchedReference;
  final TrackingItem? item;
  final String message;
  final bool fromMockService;

  bool get found => item != null;
}

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
