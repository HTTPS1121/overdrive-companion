/// Extended tunnel HTTP surface (automations, parking, trips, audio, telegram, GenAI tools).
abstract final class ExtendedEndpoints {
  // Automations
  static const automationsList = '/api/automations/list';
  static const automationsSchema = '/api/automations/schema';
  static const automationsState = '/api/automations/state';
  static const automationsSettings = '/api/automations/settings';
  static const automationsCreate = '/api/automations/automation';
  static String automationsUpdate(String id) => '/api/automations/automation/$id';
  static String automationsDelete(String id) => '/api/automations/automation/$id';
  static String automationsTest(String id) => '/api/automations/test/$id';
  static String automationsMode(String id) => '/api/automations/mode/$id';

  // Parking
  static const parkingStatus = '/api/parking/status';
  static const parkingConfig = '/api/parking/config';
  static const parkingSessions = '/api/parking/sessions';
  static String parkingSession(String id) => '/api/parking/sessions/$id';
  static String parkingSignage(String id) => '/api/parking/sessions/$id/signage';

  // Trips
  static const tripsList = '/api/trips';
  static const tripsSummary = '/api/trips/summary';
  static const tripsConfig = '/api/trips/config';
  static const tripsBootstrap = '/api/trips/bootstrap';
  static String tripDetail(String id) => '/api/trips/$id';
  static String tripDelete(String id) => '/api/trips/$id';

  // Audio library
  static const audioLibrary = '/api/audio/library';
  static const audioLibraryPlay = '/api/audio/library/play';
  static const audioLibraryStop = '/api/audio/library/stop';
  static const audioAvasState = '/api/audio/avas-state';

  // Telegram
  static const telegramStatus = '/api/telegram/status';
  static const telegramPreferences = '/api/telegram/preferences';
  static const telegramPin = '/api/telegram/pin';
  static const telegramOwnerClear = '/api/telegram/owner/clear';
  static const telegramClear = '/api/telegram/clear';

  // GenAI tools
  static const genaiRoutines = '/api/genai/routines';
  static const genaiRoutinesConfig = '/api/genai/routines/config';
  static const genaiRoutinesDecision = '/api/genai/routines/decision';
  static const genaiRoutinesReset = '/api/genai/routines/reset';
  static const genaiIncidents = '/api/genai/incidents';
  static const genaiActionExecute = '/api/genai/action/execute';

  // Platform integrations
  static const abrpStatus = '/api/abrp/status';
  static const abrpConfig = '/api/abrp/config';
  static const abrpToken = '/api/abrp/token';
  static const mqttStatus = '/api/mqtt/status';
  static const mqttConnections = '/api/mqtt/connections';
  static const mqttTelemetry = '/api/mqtt/telemetry';
  static const launcherSummary = '/api/launcher/v1/summary';
  static const launcherAppearance = '/api/launcher/v1/appearance';
  static const roadsenseHazards = '/api/roadsense/hazards';
  static const bydCloudStatus = '/api/bydcloud/status';
  static const communityList = '/api/community/list';

  // Diagnostics (read-mostly; writes require confirm upstream)
  static const debugSeatRead = '/api/debug/seat/read';
  static const logsAvailable = '/api/logs/available';
  static const logsUpload = '/api/logs/upload';
  static const debugCarPropertyStatus = '/api/debug/car-property/status';
  static const debugCarPropertyGet = '/api/debug/car-property/get';
  static const debugAdasResolve = '/api/debug/adas/resolve';
  static const debugAdasRead = '/api/debug/adas/read';
  static const debugLightResolve = '/api/debug/light/resolve';
  static const debugRemoteKey = '/api/debug/remote-key';
  static const debugAutoServiceStatus = '/api/debug/autoservice/status';
  static const debugSeatWrite = '/api/debug/seat/write';
  static const debugLightWrite = '/api/debug/light/write';
  static const debugCarPropertySet = '/api/debug/car-property/set';

  // RoadSense
  static const roadsenseDeleteLocal = '/api/roadsense/delete-local';
  static const roadsenseDeleteCloud = '/api/roadsense/delete-cloud';
  static const roadsenseTestChime = '/api/roadsense/test-chime';
  static String roadsenseHazardAction(String id, String action) =>
      '/api/roadsense/hazard/$id/$action';

  // WebSocket (companion voice clients)
  static const wsCommunicate = '/ws/communicate';
  static const wsGenAi = '/ws/genai';
}
