/// Real Overdrive HTTP paths (see VehicleControlApiHandler in Overdrive-release).
abstract final class OverdriveEndpoints {
  static const authStatus = '/auth/status';
  static const authToken = '/auth/token';

  static const vehicleState = '/api/vehicle/state';
  static const cloudStatus = '/api/vehicle/cloud-status';
  static const gps = '/api/gps';

  static const lock = '/api/vehicle/lock';
  static const unlock = '/api/vehicle/unlock';
  static const trunk = '/api/vehicle/trunk';
  static const window = '/api/vehicle/window';
  static const flash = '/api/vehicle/flash';
  static const climate = '/api/vehicle/climate';
  static const lights = '/api/vehicle/lights';
  static const findCar = '/api/vehicle/find-car';
  static const climateSchedule = '/api/vehicle/climate-schedule';
  static const chargingSchedule = '/api/vehicle/charging-schedule';
  static const startCharging = '/api/vehicle/start-charging';
  static const seat = '/api/vehicle/seat';
  static const adas = '/api/vehicle/adas';
  static const vehicleSetting = '/api/vehicle/setting';
  static const media = '/api/vehicle/media';
  static const chargeCap = '/api/vehicle/charge-cap';
  static const powerOn = '/api/vehicle/power-on';
  static const powerOff = '/api/vehicle/power-off';
  static const batteryHeat = '/api/vehicle/battery-heat';
  static const system = '/api/vehicle/system';
  static const acChargeCurrentLimit = '/api/vehicle/ac-charge-current-limit';

  static const streamStatus = '/api/stream/status';
  static const streamEnable = '/api/stream/enable';
  static const streamDisable = '/api/stream/disable';
  static const streamView = '/api/stream/view';
  static const streamQuality = '/api/stream/quality';

  static const recordings = '/api/recordings';
  static const recordingsStats = '/api/recordings/stats';
  static const surveillanceStatus = '/api/surveillance/status';
  static const surveillanceConfig = '/api/surveillance/config';
  static const surveillanceEnable = '/api/surveillance/enable';
  static const surveillanceDisable = '/api/surveillance/disable';

  static String videoById(String recordingId) => '/video/id/$recordingId';
  static String thumbById(String recordingId) => '/thumb/id/$recordingId';
  static String recordingDeleteById(String recordingId) => '/api/recordings/id/$recordingId';
  static String surveillanceSnapshot(int quadrant) => '/api/surveillance/snapshot/$quadrant';
  static const surveillanceHeatmap = '/api/surveillance/heatmap';
  static const surveillanceFilterLog = '/api/surveillance/filterlog';
  static const surveillanceScreenDeterrentImage = '/api/surveillance/screen-deterrent/image';
  static const surveillanceScreenDeterrentTest = '/api/surveillance/screen-deterrent/test';

  static const wireguardStatus = '/api/wireguard';
  static const wireguardConfig = '/api/wireguard/config';
  static const wireguardExpose = '/api/wireguard/expose';

  static const communicateStatus = '/api/communicate/status';
  static const communicateSettings = '/api/communicate/settings';
  static const communicateMessage = '/api/communicate/message';
  static const communicateTestSpeaker = '/api/communicate/test-speaker';
  static const communicateEmergencyStop = '/api/communicate/emergency-stop';

  static const genaiStatus = '/api/genai/status';
  static const genaiConfig = '/api/genai/config';
  static const genaiChat = '/api/genai/chat';
  static const genaiInsightsDashboard = '/api/genai/insights/dashboard';
  static const genaiInsights = '/api/genai/insights';
  static const genaiTest = '/api/genai/test';
  static const wireguardConfigDelete = '/api/wireguard/config';
}

enum ControlKind {
  lock,
  unlock,
  trunkOpen,
  trunkClose,
  windowsOpen,
  windowsClose,
  windowsVent,
  flash,
  findCar,
  climateOn,
  climateOff,
  tempUp,
  tempDown,
  fanUp,
  fanDown,
  readingLight,
  steeringHeat,
}

class ControlCapability {
  const ControlCapability({
    required this.kind,
    required this.path,
    this.defaultBody,
    this.requiresTyres = false,
    this.requiresConfirmation = false,
  });

  final ControlKind kind;
  final String path;
  final Map<String, dynamic>? defaultBody;
  final bool requiresTyres;
  final bool requiresConfirmation;
}

const kCompanionControls = <ControlCapability>[
  ControlCapability(kind: ControlKind.lock, path: OverdriveEndpoints.lock, requiresConfirmation: true),
  ControlCapability(kind: ControlKind.unlock, path: OverdriveEndpoints.unlock, requiresConfirmation: true),
  ControlCapability(
    kind: ControlKind.trunkOpen,
    path: OverdriveEndpoints.trunk,
    defaultBody: {'action': 'open'},
    requiresConfirmation: true,
  ),
  ControlCapability(
    kind: ControlKind.trunkClose,
    path: OverdriveEndpoints.trunk,
    defaultBody: {'action': 'close'},
  ),
  ControlCapability(
    kind: ControlKind.windowsOpen,
    path: OverdriveEndpoints.window,
    defaultBody: {'area': 0, 'command': 1},
    requiresConfirmation: true,
  ),
  ControlCapability(
    kind: ControlKind.windowsClose,
    path: OverdriveEndpoints.window,
    defaultBody: {'area': 0, 'command': 2},
  ),
  ControlCapability(
    kind: ControlKind.windowsVent,
    path: OverdriveEndpoints.window,
    defaultBody: {'action': 'vent'},
  ),
  ControlCapability(kind: ControlKind.flash, path: OverdriveEndpoints.flash),
  ControlCapability(kind: ControlKind.findCar, path: OverdriveEndpoints.findCar, requiresConfirmation: true),
  ControlCapability(
    kind: ControlKind.climateOn,
    path: OverdriveEndpoints.climate,
    defaultBody: {'action': 'power_on', 'temp': 22, 'remoteDurationMinutes': 20},
  ),
  ControlCapability(
    kind: ControlKind.climateOff,
    path: OverdriveEndpoints.climate,
    defaultBody: {'action': 'power_off'},
  ),
  ControlCapability(
    kind: ControlKind.tempUp,
    path: OverdriveEndpoints.climate,
    defaultBody: {'action': 'set_temp', 'zone': 0, 'temp': 23},
  ),
  ControlCapability(
    kind: ControlKind.tempDown,
    path: OverdriveEndpoints.climate,
    defaultBody: {'action': 'set_temp', 'zone': 0, 'temp': 21},
  ),
  ControlCapability(
    kind: ControlKind.fanUp,
    path: OverdriveEndpoints.climate,
    defaultBody: {'action': 'set_fan', 'fan': 3},
  ),
  ControlCapability(
    kind: ControlKind.fanDown,
    path: OverdriveEndpoints.climate,
    defaultBody: {'action': 'set_fan', 'fan': 1},
  ),
  ControlCapability(
    kind: ControlKind.readingLight,
    path: OverdriveEndpoints.lights,
    defaultBody: {'target': 'readingLight', 'enable': true},
  ),
  ControlCapability(
    kind: ControlKind.steeringHeat,
    path: OverdriveEndpoints.climate,
    defaultBody: {'action': 'steering_heat_on'},
  ),
];
