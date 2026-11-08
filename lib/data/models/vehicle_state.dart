class VehicleState {
  VehicleState({
    required this.success,
    this.error,
    this.doors,
    this.doorOpen,
    this.windows,
    this.battery,
    this.climate,
    this.tyres,
    this.seats,
    this.lights,
    this.timestamp,
    this.batteryHeat,
  });

  factory VehicleState.fromJson(Map<String, dynamic> json) {
    return VehicleState(
      success: json['success'] == true,
      error: json['error'] as String?,
      batteryHeat: json['batteryHeat'] as bool?,
      doors: json['doors'] != null
          ? DoorLocks.fromJson(json['doors'] as Map<String, dynamic>)
          : null,
      doorOpen: json['doorOpen'] != null
          ? DoorOpenState.fromJson(json['doorOpen'] as Map<String, dynamic>)
          : null,
      windows: json['windows'] != null
          ? WindowPercents.fromJson(json['windows'] as Map<String, dynamic>)
          : null,
      battery: json['battery'] != null
          ? BatteryInfo.fromJson(json['battery'] as Map<String, dynamic>)
          : null,
      climate: json['climate'] != null
          ? ClimateInfo.fromJson(json['climate'] as Map<String, dynamic>)
          : null,
      tyres: json['tyres'] != null
          ? TyreBlock.fromJson(json['tyres'] as Map<String, dynamic>)
          : null,
      seats: json['seats'] != null
          ? SeatInfo.fromJson(json['seats'] as Map<String, dynamic>)
          : null,
      lights: json['lights'] != null
          ? LightInfo.fromJson(json['lights'] as Map<String, dynamic>)
          : null,
      timestamp: (json['timestamp'] as num?)?.toInt(),
    );
  }

  final bool success;
  final String? error;
  final DoorLocks? doors;
  final DoorOpenState? doorOpen;
  final WindowPercents? windows;
  final BatteryInfo? battery;
  final ClimateInfo? climate;
  final TyreBlock? tyres;
  final SeatInfo? seats;
  final LightInfo? lights;
  final int? timestamp;
  /// Cloud telemetry when available (`VehicleControlApiHandler` state GET).
  final bool? batteryHeat;

  bool? get isLocked {
    final overall = doors?.overall;
    if (overall == 1) return true;
    if (overall == 2) return false;
    return null;
  }

  String lockLabelHe(bool? locked) {
    if (locked == null) return 'לא ידוע';
    return locked ? 'נעול' : 'פתוח';
  }
}

class DoorLocks {
  DoorLocks({
    this.lf,
    this.rf,
    this.lr,
    this.rr,
    this.trunk,
    this.overall,
    this.scope,
    this.source,
  });

  factory DoorLocks.fromJson(Map<String, dynamic> json) {
    int? i(String k) => (json[k] as num?)?.toInt();
    return DoorLocks(
      lf: i('lf'),
      rf: i('rf'),
      lr: i('lr'),
      rr: i('rr'),
      trunk: i('trunk'),
      overall: i('overall'),
      scope: json['scope'] as String?,
      source: json['source'] as String?,
    );
  }

  final int? lf;
  final int? rf;
  final int? lr;
  final int? rr;
  final int? trunk;
  final int? overall;
  final String? scope;
  final String? source;
}

class DoorOpenState {
  DoorOpenState({this.lf, this.rf, this.lr, this.rr, this.trunk});

  factory DoorOpenState.fromJson(Map<String, dynamic> json) {
    bool? b(String k) => json[k] as bool?;
    return DoorOpenState(
      lf: b('lf'),
      rf: b('rf'),
      lr: b('lr'),
      rr: b('rr'),
      trunk: b('trunk'),
    );
  }

  final bool? lf;
  final bool? rf;
  final bool? lr;
  final bool? rr;
  final bool? trunk;
}

class WindowPercents {
  WindowPercents({this.lf, this.rf, this.lr, this.rr, this.sunroof});

  factory WindowPercents.fromJson(Map<String, dynamic> json) {
    int? p(String k) => (json[k] as num?)?.toInt();
    return WindowPercents(
      lf: p('lf'),
      rf: p('rf'),
      lr: p('lr'),
      rr: p('rr'),
      sunroof: p('sunroof'),
    );
  }

  final int? lf;
  final int? rf;
  final int? lr;
  final int? rr;
  final int? sunroof;
}

class BatteryInfo {
  BatteryInfo({this.soc, this.rangeKm, this.bodyworkRangeKm});

  factory BatteryInfo.fromJson(Map<String, dynamic> json) {
    return BatteryInfo(
      soc: (json['soc'] as num?)?.toDouble(),
      rangeKm: (json['rangeKm'] as num?)?.toInt(),
      bodyworkRangeKm: (json['bodyworkRangeKm'] as num?)?.toInt(),
    );
  }

  final double? soc;
  final int? rangeKm;
  final int? bodyworkRangeKm;

  int? get displayRangeKm => rangeKm ?? bodyworkRangeKm;
}

class ClimateInfo {
  ClimateInfo({
    this.acOn,
    this.insideTempC,
    this.fanLevel,
    this.setpointDriver,
    this.remoteClimateActive,
  });

  factory ClimateInfo.fromJson(Map<String, dynamic> json) {
    return ClimateInfo(
      acOn: json['acOn'] as bool?,
      insideTempC: (json['insideTempC'] as num?)?.toDouble(),
      fanLevel: (json['fanLevel'] as num?)?.toInt(),
      setpointDriver: (json['setpointDriver'] as num?)?.toDouble(),
      remoteClimateActive: json['remoteClimateActive'] as bool?,
    );
  }

  final bool? acOn;
  final double? insideTempC;
  final int? fanLevel;
  final double? setpointDriver;
  final bool? remoteClimateActive;
}

class TyreCorner {
  TyreCorner({this.kPa, this.psi, this.temperatureC, this.available});

  factory TyreCorner.fromJson(Map<String, dynamic> json) {
    return TyreCorner(
      kPa: (json['kPa'] as num?)?.toInt(),
      psi: (json['psi'] as num?)?.toDouble(),
      temperatureC: (json['temperatureC'] as num?)?.toInt(),
      available: json['available'] == true,
    );
  }

  final int? kPa;
  final double? psi;
  final int? temperatureC;
  final bool? available;
}

class TyreBlock {
  TyreBlock({this.available, this.fl, this.fr, this.rl, this.rr});

  factory TyreBlock.fromJson(Map<String, dynamic> json) {
    TyreCorner? c(String k) {
      final v = json[k];
      if (v is Map<String, dynamic>) return TyreCorner.fromJson(v);
      return null;
    }

    return TyreBlock(
      available: json['available'] == true,
      fl: c('fl'),
      fr: c('fr'),
      rl: c('rl'),
      rr: c('rr'),
    );
  }

  final bool? available;
  final TyreCorner? fl;
  final TyreCorner? fr;
  final TyreCorner? rl;
  final TyreCorner? rr;
}

class SeatInfo {
  SeatInfo({
    this.steeringHeat,
    this.heat = const [0, 0],
    this.cool = const [0, 0],
    this.ventilatedSupported,
  });

  factory SeatInfo.fromJson(Map<String, dynamic> json) {
    List<int> levels(String key) {
      final raw = json[key];
      if (raw is List) {
        return raw.map((e) => (e as num).toInt()).toList();
      }
      return const [0, 0];
    }

    return SeatInfo(
      steeringHeat: json['steeringHeat'] as bool?,
      heat: levels('heat'),
      cool: levels('cool'),
      ventilatedSupported: json['ventilatedSupported'] as bool?,
    );
  }

  final bool? steeringHeat;
  final List<int> heat;
  final List<int> cool;
  final bool? ventilatedSupported;
}

class LightInfo {
  LightInfo({this.readingLight});

  factory LightInfo.fromJson(Map<String, dynamic> json) {
    return LightInfo(readingLight: json['readingLight'] as bool?);
  }

  final bool? readingLight;
}
