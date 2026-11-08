/// Parity vs Overdrive-release `VehicleControlApiHandler` / vehicle-control PWA.
class CompanionEndpointStatus {
  const CompanionEndpointStatus({
    required this.method,
    required this.path,
    required this.labelHe,
    required this.implemented,
    this.noteHe,
  });

  final String method;
  final String path;
  final String labelHe;
  final bool implemented;
  final String? noteHe;
}

const companionParityMatrix = <CompanionEndpointStatus>[
  CompanionEndpointStatus(
    method: 'GET',
    path: '/auth/status',
    labelHe: 'בדיקת חיבור',
    implemented: true,
  ),
  CompanionEndpointStatus(
    method: 'POST',
    path: '/auth/token',
    labelHe: 'אימות מכשיר',
    implemented: true,
  ),
  CompanionEndpointStatus(
    method: 'GET',
    path: '/api/vehicle/state',
    labelHe: 'מצב רכב',
    implemented: true,
  ),
  CompanionEndpointStatus(
    method: 'GET',
    path: '/api/vehicle/cloud-status',
    labelHe: 'סטטוס ענן BYD',
    implemented: true,
  ),
  CompanionEndpointStatus(
    method: 'GET',
    path: '/api/gps',
    labelHe: 'מיקום / נסיעה',
    implemented: true,
  ),
  CompanionEndpointStatus(
    method: 'POST',
    path: '/api/vehicle/lock',
    labelHe: 'נעילה',
    implemented: true,
  ),
  CompanionEndpointStatus(
    method: 'POST',
    path: '/api/vehicle/unlock',
    labelHe: 'פתיחה',
    implemented: true,
  ),
  CompanionEndpointStatus(
    method: 'POST',
    path: '/api/vehicle/trunk',
    labelHe: 'תא מטען',
    implemented: true,
  ),
  CompanionEndpointStatus(
    method: 'POST',
    path: '/api/vehicle/window',
    labelHe: 'חלונות',
    implemented: true,
  ),
  CompanionEndpointStatus(
    method: 'POST',
    path: '/api/vehicle/flash',
    labelHe: 'הבהוב',
    implemented: true,
  ),
  CompanionEndpointStatus(
    method: 'POST',
    path: '/api/vehicle/find-car',
    labelHe: 'מציאת רכב',
    implemented: false,
    noteHe: 'לא ממומש במסך שליטה בגרסה זו',
  ),
  CompanionEndpointStatus(
    method: 'POST',
    path: '/api/vehicle/climate',
    labelHe: 'מיזוג',
    implemented: true,
  ),
  CompanionEndpointStatus(
    method: 'POST',
    path: '/api/vehicle/lights',
    labelHe: 'תאורה',
    implemented: true,
  ),
  CompanionEndpointStatus(
    method: 'GET',
    path: '/api/vehicle/climate-schedule',
    labelHe: 'תזמון מיזוג',
    implemented: false,
    noteHe: 'קיים ב-PWA — לא במלווה',
  ),
  CompanionEndpointStatus(
    method: 'POST',
    path: '/api/vehicle/seat',
    labelHe: 'מושבים',
    implemented: false,
  ),
  CompanionEndpointStatus(
    method: 'POST',
    path: '/api/vehicle/charging-schedule',
    labelHe: 'תזמון טעינה',
    implemented: false,
  ),
  CompanionEndpointStatus(
    method: 'POST',
    path: '/api/vehicle/adas',
    labelHe: 'ADAS',
    implemented: false,
  ),
  CompanionEndpointStatus(
    method: 'POST',
    path: '/api/vehicle/media',
    labelHe: 'מדיה / בהירות',
    implemented: false,
  ),
];
