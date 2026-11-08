class ClimateScheduleState {
  ClimateScheduleState({
    required this.success,
    this.supported = false,
    this.reason,
    this.bookings = const [],
    this.source,
  });

  factory ClimateScheduleState.fromJson(Map<String, dynamic> json) {
    final raw = json['bookings'];
    final list = <ClimateBooking>[];
    if (raw is List) {
      for (final b in raw) {
        if (b is Map<String, dynamic>) {
          list.add(ClimateBooking.fromJson(b));
        }
      }
    }
    return ClimateScheduleState(
      success: json['success'] == true,
      supported: json['supported'] == true,
      reason: json['reason'] as String?,
      bookings: list,
      source: json['source'] as String?,
    );
  }

  final bool success;
  final bool supported;
  final String? reason;
  final List<ClimateBooking> bookings;
  final String? source;
}

class ClimateBooking {
  ClimateBooking({
    this.bookingId,
    this.bookingTime,
    this.temp,
    this.durationMinutes,
  });

  factory ClimateBooking.fromJson(Map<String, dynamic> json) {
    return ClimateBooking(
      bookingId: json['bookingId']?.toString(),
      bookingTime: (json['bookingTime'] as num?)?.toInt(),
      temp: (json['temp'] as num?)?.toDouble(),
      durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
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
    return ChargingScheduleState(
      success: json['success'] == true,
      supported: json['supported'] == true,
      reason: json['reason'] as String?,
      enabled: json['enabled'] as bool?,
      startChargeTime: json['startChargeTime']?.toString(),
      endChargeTime: json['endChargeTime']?.toString(),
      chargeWay: json['chargeWay']?.toString(),
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
