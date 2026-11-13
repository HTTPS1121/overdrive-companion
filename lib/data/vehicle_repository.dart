import '../models/companion_models.dart';

abstract class VehicleRepository {
  String get carName;
  String get carTrim;
  int get rangeKm;
  int get batteryPercent;
  bool get locked;
  bool get powered;
  bool get trunkOpen;
  String get refreshLabel;
  bool get vehicleStateStale;
  String? get vehicleOfflineHebrew;

  bool get recordingsKnown;
  DataLoadState get recordingsState;
  String? get recordingsErrorHebrew;

  bool get streamKnown;
  DataLoadState get streamState;
  String? get streamErrorHebrew;

  List<Recording> get recordings;
  List<String> get placeFilters;

  bool get tripsKnown;
  DataLoadState get tripsState;
  String? get tripsErrorHebrew;
  List<TripSummary> get trips;

  Future<void> refreshVehicleState();
  Future<void> refreshRecordings();
  Future<void> refreshStreamStatus();
  Future<void> refreshTrips();

  Future<CommandResult> runCompanionAction(String actionId);
}
