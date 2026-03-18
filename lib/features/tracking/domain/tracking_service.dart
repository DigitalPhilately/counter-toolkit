import 'package:counter_toolkit/features/tracking/domain/tracking_models.dart';

abstract class TrackingService {
  const TrackingService();

  List<String> get sampleReferences;

  Future<TrackingLookupOutcome> lookup(String reference);
}
