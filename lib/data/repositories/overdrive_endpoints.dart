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
    required this.labelHe,
    this.defaultBody,
    this.requiresTyres = false,
  });

  final ControlKind kind;
  final String path;
  final String labelHe;
  final Map<String, dynamic>? defaultBody;
  final bool requiresTyres;
}

/// Controls implemented in this companion (subset of VehicleControlApiHandler).
const kCompanionControls = <ControlCapability>[
  ControlCapability(
    kind: ControlKind.lock,
    path: OverdriveEndpoints.lock,
    labelHe: 'נעילה',
  ),
  ControlCapability(
    kind: ControlKind.unlock,
    path: OverdriveEndpoints.unlock,
    labelHe: 'פתיחה',
  ),
  ControlCapability(
    kind: ControlKind.trunkOpen,
    path: OverdriveEndpoints.trunk,
    labelHe: 'פתיחת תא מטען',
    defaultBody: {'action': 'open'},
  ),
  ControlCapability(
    kind: ControlKind.trunkClose,
    path: OverdriveEndpoints.trunk,
    labelHe: 'סגירת תא מטען',
    defaultBody: {'action': 'close'},
  ),
  ControlCapability(
    kind: ControlKind.windowsOpen,
    path: OverdriveEndpoints.window,
    labelHe: 'פתיחת חלונות',
    defaultBody: {'area': 0, 'command': 1},
  ),
  ControlCapability(
    kind: ControlKind.windowsClose,
    path: OverdriveEndpoints.window,
    labelHe: 'סגירת חלונות',
    defaultBody: {'area': 0, 'command': 2},
  ),
  ControlCapability(
    kind: ControlKind.windowsVent,
    path: OverdriveEndpoints.window,
    labelHe: 'אוורור חלונות',
    defaultBody: {'action': 'vent'},
  ),
  ControlCapability(
    kind: ControlKind.flash,
    path: OverdriveEndpoints.flash,
    labelHe: 'הבהוב אורות',
  ),
  ControlCapability(
    kind: ControlKind.climateOn,
    path: OverdriveEndpoints.climate,
    labelHe: 'הפעלת מיזוג',
    defaultBody: {'action': 'power_on', 'temp': 22, 'remoteDurationMinutes': 20},
  ),
  ControlCapability(
    kind: ControlKind.climateOff,
    path: OverdriveEndpoints.climate,
    labelHe: 'כיבוי מיזוג',
    defaultBody: {'action': 'power_off'},
  ),
  ControlCapability(
    kind: ControlKind.tempUp,
    path: OverdriveEndpoints.climate,
    labelHe: 'טמפ׳ +',
    defaultBody: {'action': 'set_temp', 'zone': 0, 'temp': 23},
  ),
  ControlCapability(
    kind: ControlKind.tempDown,
    path: OverdriveEndpoints.climate,
    labelHe: 'טמפ׳ -',
    defaultBody: {'action': 'set_temp', 'zone': 0, 'temp': 21},
  ),
  ControlCapability(
    kind: ControlKind.fanUp,
    path: OverdriveEndpoints.climate,
    labelHe: 'מאוורר +',
    defaultBody: {'action': 'set_fan', 'fan': 3},
  ),
  ControlCapability(
    kind: ControlKind.fanDown,
    path: OverdriveEndpoints.climate,
    labelHe: 'מאוורר -',
    defaultBody: {'action': 'set_fan', 'fan': 1},
  ),
  ControlCapability(
    kind: ControlKind.readingLight,
    path: OverdriveEndpoints.lights,
    labelHe: 'אור קריאה',
    defaultBody: {'target': 'readingLight', 'enable': true},
  ),
  ControlCapability(
    kind: ControlKind.steeringHeat,
    path: OverdriveEndpoints.climate,
    labelHe: 'חימום הגה',
    defaultBody: {'action': 'steering_heat_on'},
  ),
];
