/// Matches Overdrive `login.html`: full device token is `{deviceId}-{accessCode}`.
String composeDeviceToken({
  required String deviceId,
  required String accessCode,
}) {
  final id = deviceId.trim();
  final code = accessCode.trim().toLowerCase();
  if (id.isEmpty || code.isEmpty) return '';
  return '$id-$code';
}

/// Splits a stored full token into id + code when dash-separated.
({String deviceId, String accessCode})? parseDeviceToken(String full) {
  final trimmed = full.trim();
  final dash = trimmed.lastIndexOf('-');
  if (dash <= 0 || dash >= trimmed.length - 1) return null;
  return (
    deviceId: trimmed.substring(0, dash),
    accessCode: trimmed.substring(dash + 1),
  );
}

bool isPlausibleAccessCode(String code) => code.trim().length >= 8;
