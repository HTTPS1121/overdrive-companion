/// Parity vs Overdrive-release `VehicleControlApiHandler` / vehicle-control PWA.
/// Documented in docs/FEATURE_PARITY.md — not shown in production Settings UI.
class CompanionEndpointStatus {
  const CompanionEndpointStatus({
    required this.method,
    required this.path,
    required this.labelHe,
    required this.implemented,
    this.noteHe,
    this.carOnlyReason,
  });

  final String method;
  final String path;
  final String labelHe;
  final bool implemented;
  final String? noteHe;
  /// Head-unit / daemon only — not exposed on tunnel phone client.
  final String? carOnlyReason;
}

const companionParityMatrix = <CompanionEndpointStatus>[
  CompanionEndpointStatus(method: 'GET', path: '/auth/status', labelHe: 'בדיקת חיבור', implemented: true),
  CompanionEndpointStatus(method: 'POST', path: '/auth/token', labelHe: 'אימות מכשיר', implemented: true),
  CompanionEndpointStatus(method: 'GET', path: '/api/vehicle/state', labelHe: 'מצב רכב', implemented: true),
  CompanionEndpointStatus(method: 'GET', path: '/api/vehicle/cloud-status', labelHe: 'סטטוס ענן BYD', implemented: true),
  CompanionEndpointStatus(method: 'GET', path: '/api/gps', labelHe: 'מיקום / נסיעה', implemented: true),
  CompanionEndpointStatus(method: 'POST', path: '/api/vehicle/lock', labelHe: 'נעילה', implemented: true),
  CompanionEndpointStatus(method: 'POST', path: '/api/vehicle/unlock', labelHe: 'פתיחה', implemented: true),
  CompanionEndpointStatus(method: 'POST', path: '/api/vehicle/trunk', labelHe: 'תא מטען', implemented: true),
  CompanionEndpointStatus(method: 'POST', path: '/api/vehicle/window', labelHe: 'חלונות', implemented: true),
  CompanionEndpointStatus(method: 'POST', path: '/api/vehicle/flash', labelHe: 'הבהוב', implemented: true),
  CompanionEndpointStatus(method: 'POST', path: '/api/vehicle/find-car', labelHe: 'מציאת רכב', implemented: true),
  CompanionEndpointStatus(method: 'POST', path: '/api/vehicle/climate', labelHe: 'מיזוג', implemented: true),
  CompanionEndpointStatus(method: 'POST', path: '/api/vehicle/lights', labelHe: 'תאורה', implemented: true),
  CompanionEndpointStatus(method: 'GET', path: '/api/vehicle/climate-schedule', labelHe: 'תזמון מיזוג', implemented: true),
  CompanionEndpointStatus(method: 'POST', path: '/api/vehicle/climate-schedule', labelHe: 'עריכת תזמון מיזוג', implemented: true),
  CompanionEndpointStatus(method: 'GET', path: '/api/vehicle/charging-schedule', labelHe: 'תזמון טעינה', implemented: true),
  CompanionEndpointStatus(method: 'POST', path: '/api/vehicle/charging-schedule', labelHe: 'עריכת תזמון טעינה', implemented: true),
  CompanionEndpointStatus(method: 'POST', path: '/api/vehicle/start-charging', labelHe: 'התחלת טעינה', implemented: true),
  CompanionEndpointStatus(method: 'POST', path: '/api/vehicle/seat', labelHe: 'מושבים', implemented: true),
  CompanionEndpointStatus(method: 'GET', path: '/api/vehicle/adas', labelHe: 'מצב ADAS', implemented: true),
  CompanionEndpointStatus(method: 'POST', path: '/api/vehicle/adas', labelHe: 'ADAS', implemented: true),
  CompanionEndpointStatus(method: 'POST', path: '/api/vehicle/setting', labelHe: 'הגדרות רכב', implemented: true),
  CompanionEndpointStatus(method: 'POST', path: '/api/vehicle/media', labelHe: 'מדיה / בהירות', implemented: true),
  CompanionEndpointStatus(method: 'GET', path: '/api/vehicle/charge-cap', labelHe: 'מגבלת טעינה', implemented: true),
  CompanionEndpointStatus(method: 'POST', path: '/api/vehicle/charge-cap', labelHe: 'שמירת מגבלת טעינה', implemented: true),
  CompanionEndpointStatus(
    method: 'POST',
    path: '/api/vehicle/system',
    labelHe: 'ניווט מערכת / צילום',
    implemented: false,
    carOnlyReason: 'דורש UI ברכב — VehicleControlApiHandler.handleSystem',
  ),
  CompanionEndpointStatus(
    method: 'POST',
    path: '/api/vehicle/cluster-cast',
    labelHe: 'שידור למסך לוח',
    implemented: false,
    carOnlyReason: 'מסך projection ברכב בלבד',
  ),
  CompanionEndpointStatus(
    method: 'GET',
    path: '/api/vehicle/cluster-apps',
    labelHe: 'רשימת אפליקציות ללוח',
    implemented: false,
    carOnlyReason: 'מסך projection ברכב בלבד',
  ),
];
