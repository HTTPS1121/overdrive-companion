/// Models aligned with Overdrive-release VehicleControlApiHandler + vehicle-control.js.

class ClimateScheduleState {
  ClimateScheduleState({
    required this.success,
    this.supported = false,
    this.reason,
    this.bookings = const [],
    this.source,
    this.bookingsUnavailable = false,
    this.emptyBookingsMayBeStale = false,
  });

  factory ClimateScheduleState.fromJson(Map<String, dynamic> json) {
    final list = <ClimateBooking>[];
    final rawBookings = json['bookings'];
    if (json['bookingsUnavailable'] == true) {
      // Omit list — stale; do not treat as empty schedule.
    } else if (rawBookings is Map<String, dynamic>) {
      final entries = rawBookings['listInfo'];
      if (entries is List) {
        for (final e in entries) {
          if (e is Map<String, dynamic>) {
            list.add(ClimateBooking.fromCloudListEntry(e));
          }
        }
      }
    } else if (rawBookings is List) {
      for (final e in rawBookings) {
        if (e is Map<String, dynamic>) {
          list.add(ClimateBooking.fromCloudListEntry(e));
        }
      }
    }

    return ClimateScheduleState(
      success: json['success'] == true,
      supported: json['supported'] == true,
      reason: json['reason'] as String?,
      bookings: list,
      source: json['source'] as String?,
      bookingsUnavailable: json['bookingsUnavailable'] == true,
      emptyBookingsMayBeStale: json['emptyBookingsMayBeStale'] == true,
    );
  }

  final bool success;
  final bool supported;
  final String? reason;
  final List<ClimateBooking> bookings;
  final String? source;
  final bool bookingsUnavailable;
  final bool emptyBookingsMayBeStale;
}

class ClimateBooking {
  ClimateBooking({
    this.bookingId,
    this.bookingTime,
    this.temp,
    this.durationMinutes,
  });

  /// BYD cloud list entry (`listInfo[]`) per vehicle-control.js.
  factory ClimateBooking.fromCloudListEntry(Map<String, dynamic> json) {
    final id = json['bookingId']?.toString();
    int? when;
    final bt = json['bookingTime'] ?? json['bookTime'] ?? json['appointmentTime'];
    if (bt is num) {
      final v = bt.toInt();
      if (v > 1000000000 && v < 4000000000) when = v;
    }
    double? tempC;
    final rawTemp = json['mainSettingTemp'];
    if (rawTemp is num) {
      final raw = rawTemp.toInt();
      if (raw >= 1 && raw <= 17) tempC = (raw + 14).toDouble();
    }
    final tempPlain = json['temp'];
    if (tempC == null && tempPlain is num) {
      tempC = tempPlain.toDouble();
    }
    int? duration;
    final span = json['timeSpan'] ?? json['timespan'];
    if (span is num && span >= 1 && span <= 5) {
      duration = span.toInt() * 5 + 5;
    }
    final dur = json['durationMinutes'];
    if (duration == null && dur is num) duration = dur.toInt();

    return ClimateBooking(
      bookingId: id,
      bookingTime: when,
      temp: tempC,
      durationMinutes: duration,
    );
  }

  final String? bookingId;
  final int? bookingTime;
  final double? temp;
  final int? durationMinutes;
}

class ChargingScheduleState {
  ChargingScheduleState({
    required this.success,
    this.supported = false,
    this.reason,
    this.enabled,
    this.startChargeTime,
    this.endChargeTime,
    this.chargeWay,
    this.source,
  });

  factory ChargingScheduleState.fromJson(Map<String, dynamic> json) {
    bool? enabled;
    final en = json['enabled'];
    if (en is bool) enabled = en;

    String? t(String k) {
      final v = json[k];
      if (v == null) return null;
      final s = v.toString();
      if (s == 'null' || s.isEmpty) return null;
      return s;
    }

    return ChargingScheduleState(
      success: json['success'] == true,
      supported: json['supported'] == true,
      reason: json['reason'] as String?,
      enabled: enabled,
      startChargeTime: t('startChargeTime'),
      endChargeTime: t('endChargeTime'),
      chargeWay: t('chargeWay'),
      source: json['source'] as String?,
    );
  }

  final bool success;
  final bool supported;
  final String? reason;
  final bool? enabled;
  final String? startChargeTime;
  final String? endChargeTime;
  final String? chargeWay;
  final String? source;
}

class AdasState {
  AdasState({
    required this.success,
    this.espOn,
    this.itacOn,
  });

  factory AdasState.fromJson(Map<String, dynamic> json) {
    final esp = json['esp'] as Map<String, dynamic>?;
    final itac = json['itac'] as Map<String, dynamic>?;
    return AdasState(
      success: json['success'] == true,
      espOn: esp?['on'] as bool?,
      itacOn: itac?['on'] as bool?,
    );
  }

  final bool success;
  final bool? espOn;
  final bool? itacOn;
}

class ChargeCapState {
  ChargeCapState({
    required this.success,
    this.supported = false,
    this.percent,
    this.enabled,
  });

  factory ChargeCapState.fromJson(Map<String, dynamic> json) {
    return ChargeCapState(
      success: json['success'] == true,
      supported: json['supported'] == true,
      percent: (json['percent'] as num?)?.toInt(),
      enabled: json['enabled'] as bool?,
    );
  }

  final bool success;
  final bool supported;
  final int? percent;
  final bool? enabled;
}
