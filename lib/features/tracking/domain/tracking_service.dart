import 'package:counter_toolkit/features/tracking/domain/tracking_models.dart';

abstract class TrackingService {
  const TrackingService();

  List<String> get sampleReferences;

  List<TrackingLookupMode> get supportedModes;

  List<TrackingProviderGuide> get providerGuides;

  Future<TrackingLookupOutcome> lookup(TrackingLookupRequest request);
}
