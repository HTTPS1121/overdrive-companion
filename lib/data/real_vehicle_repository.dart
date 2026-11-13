import 'dart:async';
import 'dart:convert';

import 'package:overdrive_server/overdrive_server.dart';

import '../models/companion_models.dart';
import 'hebrew_errors.dart';
import 'network_errors.dart';
import 'vehicle_repository.dart';

const _commandTimeout = Duration(seconds: 45);
const _readTimeout = Duration(seconds: 30);

class RealVehicleRepository implements VehicleRepository {
  RealVehicleRepository(this._client);

  OverdriveApiClient _client;

  void updateClient(OverdriveApiClient client) => _client = client;

  @override
  String carName = '—';
  @override
  String carTrim = '';
  @override
  int rangeKm = 0;
  @override
  int batteryPercent = 0;
  @override
  bool locked = true;
  @override
  bool powered = false;
  @override
  bool trunkOpen = false;
  @override
  String refreshLabel = 'ממתין לנתונים…';

  @override
  bool vehicleStateStale = false;
  @override
  String? vehicleOfflineHebrew;

  @override
  bool recordingsKnown = false;
  @override
  DataLoadState recordingsState = DataLoadState.idle;
  @override
  String? recordingsErrorHebrew;

  @override
  bool streamKnown = false;
  @override
  DataLoadState streamState = DataLoadState.idle;
  @override
  String? streamErrorHebrew;

  @override
  bool tripsKnown = false;
  @override
  DataLoadState tripsState = DataLoadState.idle;
  @override
  String? tripsErrorHebrew;

  DateTime? _lastVehicleRefresh;
  List<Recording> _recordings = [];
  List<String> _placeFilters = [];
  List<TripSummary> _trips = [];
  VehicleStatusSnapshot _vehicleStatus = const VehicleStatusSnapshot(doorsLine: '—');
  RecordingStatsSnapshot _recordingStats = const RecordingStatsSnapshot(available: false);

  @override
  List<Recording> get recordings => List.unmodifiable(_recordings);

  @override
  List<String> get placeFilters => List.unmodifiable(_placeFilters);

  @override
  List<TripSummary> get trips => List.unmodifiable(_trips);

  @override
  VehicleStatusSnapshot get vehicleStatus => _vehicleStatus;

  @override
  RecordingStatsSnapshot get recordingStats => _recordingStats;

  @override
  Future<void> refreshVehicleState() async {
    try {
      final json = await _client
          .getJson(OverdriveEndpoints.vehicleState)
          .timeout(_readTimeout);
      _applyVehicleState(json);
      vehicleStateStale = false;
      vehicleOfflineHebrew = null;
    } on TimeoutException catch (e) {
      _markVehicleStale(hebrewFromAnyError(e));
    } on OverdriveApiException catch (e) {
      _markVehicleStale(hebrewFromAnyError(e));
    } catch (e) {
      _markVehicleStale(hebrewFromAnyError(e));
    }
  }

  void applyVehicleStateJson(Map<String, dynamic> json) => _applyVehicleState(json);

  void _applyVehicleState(Map<String, dynamic> json) {
    final battery = json['battery'] as Map<String, dynamic>?;
    rangeKm = (battery?['rangeKm'] as num?)?.round() ?? (battery?['bodyworkRangeKm'] as num?)?.round() ?? 0;
    batteryPercent = (battery?['soc'] as num?)?.round() ?? 0;

    final doors = json['doors'] as Map<String, dynamic>?;
    locked = (doors?['overall'] as num?)?.toInt() == 1;

    final trunk = json['trunk'] as Map<String, dynamic>?;
    trunkOpen = trunk?['open'] == true;

    powered = json['powerOn'] == true || (json['climate'] as Map?)?['remoteClimateActive'] == true;

    carName = (json['vehicleName'] ?? json['model'] ?? 'הרכב שלי').toString();
    carTrim = (json['trim'] ?? '').toString();

    _lastVehicleRefresh = DateTime.now();
    final ts = (json['timestamp'] as num?)?.toInt();
    refreshLabel = ts != null ? _freshnessLabel(ts) : 'מעודכן מהשרת';
    _vehicleStatus = _parseVehicleStatus(json, locked);
  }

  VehicleStatusSnapshot _parseVehicleStatus(Map<String, dynamic> json, bool doorsLocked) {
    final doorsLine = doorsLocked ? 'נעולות' : 'פתוחות לנעילה';

    String? windowsLine;
    final windowOpen = json['windowOpen'] as Map<String, dynamic>?;
    if (windowOpen != null) {
      final anyOpen = windowOpen.values.any((v) => v == true);
      windowsLine = anyOpen ? 'פתוחים' : 'סגורים';
    }

    String? climateLine;
    final climate = json['climate'] as Map<String, dynamic>?;
    if (climate != null) {
      final setpoint = (climate['setpointDriver'] as num?)?.round();
      final active = climate['acOn'] == true || climate['remoteClimateActive'] == true;
      if (setpoint != null) {
        climateLine = '$setpoint° · ${active ? 'פועל' : 'כבוי'}';
      } else if (climate.containsKey('acOn') || climate.containsKey('remoteClimateActive')) {
        climateLine = active ? 'פועל' : 'כבוי';
      }
    }

    String? tyresLine;
    final tyres = json['tyres'] as Map<String, dynamic>?;
    if (tyres != null && tyres['available'] == true) {
      final parts = <String>[];
      for (final key in ['fl', 'fr', 'rl', 'rr']) {
        final wheel = tyres[key] as Map<String, dynamic>?;
        if (wheel == null || wheel['available'] != true) continue;
        final psi = (wheel['psi'] as num?)?.toDouble();
        if (psi != null) {
          parts.add(psi.toStringAsFixed(1));
        }
      }
      if (parts.length == 4) tyresLine = parts.join(' · ');
    }

    String? driveLine;
    final gear = json['gear'] ?? json['transmission'];
    final speed = (json['speedKmh'] as num?) ?? (json['speed'] as num?);
    if (gear != null || speed != null) {
      final g = gear?.toString() ?? '—';
      final spd = speed != null ? '${speed.round()} קמ״ש' : '—';
      driveLine = '$g · $spd';
    }

    String? sentryLine;
    final sentry = json['sentry'] ?? json['surveillance'];
    if (sentry is Map) {
      final armed = sentry['armed'] == true || sentry['enabled'] == true || sentry['active'] == true;
      sentryLine = armed ? 'דרוך' : 'מושבת';
    }

    String? chargingLine;
    String? chargeCapLine;
    final battery = json['battery'] as Map<String, dynamic>?;
    if (battery != null) {
      final charging = battery['charging'] == true || battery['isCharging'] == true;
      if (battery.containsKey('charging') || battery.containsKey('isCharging')) {
        chargingLine = charging ? 'בטעינה' : 'לא בטעינה';
      }
      final cap = (battery['chargeLimitPercent'] as num?) ??
          (battery['acChargeLimitPercent'] as num?) ??
          (json['chargeCap'] as Map?)?['limitPercent'] as num?;
      if (cap != null) {
        chargeCapLine = 'מגבלת טעינה ${cap.round()}%';
      }
    }

    return VehicleStatusSnapshot(
      doorsLine: doorsLine,
      windowsLine: windowsLine,
      climateLine: climateLine,
      tyresLine: tyresLine,
      driveLine: driveLine,
      sentryLine: sentryLine,
      chargingLine: chargingLine,
      chargeCapLine: chargeCapLine,
    );
  }

  void _markVehicleStale(String message) {
    vehicleStateStale = true;
    vehicleOfflineHebrew = message;
    if (_lastVehicleRefresh != null) {
      refreshLabel = hebrewStaleVehicleLabel(_lastVehicleRefresh!);
    } else {
      refreshLabel = message;
    }
  }

  String _freshnessLabel(int epochSec) {
    final age = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(epochSec * 1000));
    if (age.inMinutes < 2) return 'עודכן זה עתה';
    if (age.inMinutes < 60) return 'עודכן לפני ${age.inMinutes} דק׳';
    if (age.inHours < 24) return 'עודכן לפני ${age.inHours} שע׳';
    return 'עודכן לפני ${age.inDays} ימים';
  }

  @override
  Future<void> refreshRecordings() async {
    recordingsState = DataLoadState.loading;
    recordingsErrorHebrew = null;
    try {
      final json = await _client.getJson(OverdriveEndpoints.recordings).timeout(_readTimeout);
      final list = _parseRecordingsList(json);
      _recordings = list;
      _placeFilters = list.map((r) => r.shortPlace).where((p) => p.isNotEmpty).toSet().toList()..sort();
      recordingsKnown = true;
      recordingsState = list.isEmpty ? DataLoadState.empty : DataLoadState.ready;
      await _refreshRecordingStats();
    } on TimeoutException catch (e) {
      recordingsKnown = true;
      recordingsState = DataLoadState.error;
      recordingsErrorHebrew = hebrewFromAnyError(e);
    } on OverdriveApiException catch (e) {
      recordingsKnown = true;
      recordingsState = DataLoadState.error;
      recordingsErrorHebrew = hebrewFromAnyError(e);
    } catch (e) {
      recordingsKnown = true;
      recordingsState = DataLoadState.error;
      recordingsErrorHebrew = hebrewFromAnyError(e);
    }
  }

  Future<void> _refreshRecordingStats() async {
    try {
      final json = await _client.getJson(OverdriveEndpoints.recordingsStats).timeout(_readTimeout);
      if (json['success'] == false) {
        _recordingStats = const RecordingStatsSnapshot(available: false);
        return;
      }
      final usagePct = (json['recordingsUsagePercent'] as num?)?.toDouble();
      final totalSize = json['totalSizeFormatted'] as String? ?? json['totalSize']?.toString();
      double? fraction;
      if (usagePct != null) {
        fraction = (usagePct / 100).clamp(0.0, 1.0);
      } else {
        final used = json['totalSize'] as num?;
        final cap = json['totalSpace'] as num? ?? json['recordingsLimitBytes'] as num?;
        if (used != null && cap != null && cap > 0) {
          fraction = (used / cap).clamp(0.0, 1.0);
        }
      }
      final oem = json['oemDvrLabel'] as String? ??
          json['dvrLabel'] as String? ??
          json['storageSourceLabel'] as String?;
      final trimmedOem = oem?.trim();
      _recordingStats = RecordingStatsSnapshot(
        available: totalSize != null || fraction != null,
        totalSizeFormatted: totalSize,
        usageFraction: fraction,
        oemDvrLabel: trimmedOem != null && trimmedOem.isNotEmpty ? trimmedOem : null,
        totalTodayCount: (json['totalTodayCount'] as num?)?.toInt(),
      );
    } on OverdriveApiException catch (e) {
      if (e.statusCode == 404) {
        _recordingStats = const RecordingStatsSnapshot(available: false);
        return;
      }
      _recordingStats = const RecordingStatsSnapshot(available: false);
    } catch (_) {
      _recordingStats = const RecordingStatsSnapshot(available: false);
    }
  }

  List<Recording> _parseRecordingsList(Map<String, dynamic> json) {
    final raw = json['recordings'] ?? json['items'] ?? json['data'];
    if (raw is! List) return [];
    final out = <Recording>[];
    var id = 0;
    for (final item in raw) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);
      final recId = map['id']?.toString() ?? '$id';
      id++;
      out.add(
        Recording(
          id: id,
          day: (map['day'] ?? map['dateLabel'] ?? '').toString(),
          type: _recordingType(map['type']),
          typeLabel: (map['typeLabel'] ?? map['type'] ?? 'הקלטה').toString(),
          time: (map['time'] ?? map['startTime'] ?? '').toString(),
          dur: (map['duration'] ?? map['dur'] ?? '').toString(),
          size: (map['size'] ?? map['sizeLabel'] ?? '').toString(),
          storage: (map['storage'] ?? '').toString(),
          storageLabel: (map['storageLabel'] ?? map['storage'] ?? '').toString(),
          place: (map['place'] ?? '').toString(),
          shortPlace: (map['shortPlace'] ?? map['place'] ?? '').toString(),
          actor: (map['actor'] ?? map['class'] ?? '').toString(),
          actorLabel: (map['actorLabel'] ?? '').toString(),
          sev: (map['severity'] ?? map['sev'] ?? '').toString(),
          sevLabel: (map['sevLabel'] ?? '').toString(),
          prox: (map['proximity'] ?? map['prox'] ?? '').toString(),
          proxLabel: (map['proxLabel'] ?? '').toString(),
          trigger: (map['trigger'] ?? '').toString(),
          file: recId,
          thumbPath: map['thumbPath'] as String? ?? map['thumbnail'] as String?,
          cameraLabel: _optionalStr(map['camera'] ?? map['cameraLabel'] ?? map['cam']),
          cameraAngles: _parseCameraAngles(map),
        ),
      );
    }
    return out;
  }

  List<String> _parseCameraAngles(Map<String, dynamic> map) {
    final raw = map['cameras'] ?? map['angles'] ?? map['files'];
    if (raw is List && raw.isNotEmpty) {
      return raw.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
    }
    return const [];
  }

  @override
  Future<void> refreshTrips() async {
    tripsState = DataLoadState.loading;
    tripsErrorHebrew = null;
    try {
      final json = await _client
          .getJson('${OverdriveEndpoints.trips}?days=14&limit=30')
          .timeout(_readTimeout);
      final raw = json['trips'];
      final parsed = <TripSummary>[];
      if (raw is List) {
        for (final item in raw) {
          if (item is! Map) continue;
          final map = Map<String, dynamic>.from(item);
          parsed.add(_parseTrip(map));
        }
      }
      _trips = parsed;
      tripsKnown = true;
      tripsState = parsed.isEmpty ? DataLoadState.empty : DataLoadState.ready;
    } on OverdriveApiException catch (e) {
      tripsKnown = true;
      if (e.statusCode == 404) {
        _trips = [];
        tripsState = DataLoadState.empty;
        tripsErrorHebrew = null;
        return;
      }
      tripsState = DataLoadState.error;
      tripsErrorHebrew = hebrewFromAnyError(e);
    } catch (e) {
      tripsKnown = true;
      tripsState = DataLoadState.error;
      tripsErrorHebrew = hebrewFromAnyError(e);
    }
  }

  TripSummary _parseTrip(Map<String, dynamic> map) {
    final id = (map['id'] as num?)?.toInt() ?? 0;
    final start = (map['startTime'] as num?)?.toInt() ?? 0;
    final end = (map['endTime'] as num?)?.toInt() ?? start;
    final dist = (map['distanceKm'] as num?)?.toDouble() ?? 0;
    final dur = (map['durationSeconds'] as num?)?.toInt() ?? 0;
    final score = (map['overallScore'] as num?)?.toInt() ?? 0;
    final when = DateTime.fromMillisecondsSinceEpoch(start);
    final hh = when.hour.toString().padLeft(2, '0');
    final mm = when.minute.toString().padLeft(2, '0');
    final subtitle = '${dist.toStringAsFixed(1)} ק״מ · ${dur ~/ 60} דק׳ · DNA $score · $hh:$mm';
    return TripSummary(
      id: id,
      startTimeMs: start,
      endTimeMs: end,
      distanceKm: dist,
      durationSeconds: dur,
      overallScore: score,
      subtitle: subtitle,
    );
  }

  RecordingType _recordingType(Object? raw) {
    final s = raw?.toString().toLowerCase() ?? '';
    if (s.contains('sentry')) return RecordingType.sentry;
    if (s.contains('prox')) return RecordingType.proximity;
    if (s.contains('replay')) return RecordingType.replay;
    return RecordingType.normal;
  }

  @override
  Future<void> refreshStreamStatus() async {
    streamState = DataLoadState.loading;
    streamErrorHebrew = null;
    try {
      final json = await _client.getJson(OverdriveEndpoints.streamStatus).timeout(_readTimeout);
      final active = json['active'] == true || json['enabled'] == true || json['streaming'] == true;
      streamKnown = true;
      streamState = active ? DataLoadState.ready : DataLoadState.empty;
      if (!active) streamErrorHebrew = hebrewStreamUnavailable();
    } on TimeoutException catch (e) {
      streamKnown = true;
      streamState = DataLoadState.error;
      streamErrorHebrew = hebrewFromAnyError(e);
    } on OverdriveApiException catch (e) {
      streamKnown = true;
      streamState = DataLoadState.error;
      streamErrorHebrew = hebrewFromAnyError(e);
    } catch (e) {
      streamKnown = true;
      streamState = DataLoadState.error;
      streamErrorHebrew = hebrewFromAnyError(e);
    }
  }

  @override
  Future<CommandResult> runServerControl(ControlKind kind) async {
    final cap = kCompanionControls.firstWhere(
      (c) => c.kind == kind,
      orElse: () => throw ArgumentError('Unknown control $kind'),
    );
    try {
      final json = await _client
          .postJson(cap.path, body: cap.defaultBody ?? const {})
          .timeout(_commandTimeout);
      final ok = json['success'] != false && json['commandSuccess'] != false;
      if (!ok) {
        return CommandResult.fail(
          hebrewCommandRejected(json['error'] as String? ?? json['message'] as String?),
        );
      }
      try {
        await refreshVehicleState();
      } catch (_) {}
      final msg = json['message'] as String?;
      return CommandResult.ok(msg);
    } on TimeoutException catch (e) {
      return CommandResult.fail(hebrewFromAnyError(e));
    } on OverdriveApiException catch (e) {
      if (e.statusCode == 404) {
        return CommandResult.fail(hebrewFeatureNotOnServer());
      }
      return CommandResult.fail(hebrewFromAnyError(e));
    } catch (e) {
      return CommandResult.fail(hebrewFromAnyError(e));
    }
  }

  @override
  Future<CommandResult> runCompanionAction(String actionId) async {
    final spec = _actionSpec(actionId);
    if (spec == null) {
      return CommandResult.fail('פקודה לא מזוהה.');
    }
    try {
      final json = await _client
          .postJson(spec.path, body: spec.body)
          .timeout(_commandTimeout);
      final ok = json['success'] != false && json['commandSuccess'] != false;
      if (!ok) {
        return CommandResult.fail(
          hebrewCommandRejected(json['error'] as String? ?? json['message'] as String?),
        );
      }
      try {
        await refreshVehicleState();
      } catch (_) {}
      final msg = json['message'] as String?;
      return CommandResult.ok(msg);
    } on TimeoutException catch (e) {
      return CommandResult.fail(hebrewFromAnyError(e));
    } on OverdriveApiException catch (e) {
      return CommandResult.fail(hebrewFromAnyError(e));
    } catch (e) {
      return CommandResult.fail(hebrewFromAnyError(e));
    }
  }

  _ActionSpec? _actionSpec(String actionId) => switch (actionId) {
        'lock' => _ActionSpec(OverdriveEndpoints.lock, const {}),
        'unlock' => _ActionSpec(OverdriveEndpoints.unlock, const {}),
        'power' => _ActionSpec(OverdriveEndpoints.powerOn, const {}),
        'off' => _ActionSpec(OverdriveEndpoints.powerOff, const {}),
        'trunk' => _ActionSpec(OverdriveEndpoints.trunk, {'action': 'open'}),
        'down' => _ActionSpec(OverdriveEndpoints.trunk, {'action': 'close'}),
        'flash' => _ActionSpec(OverdriveEndpoints.flash, const {}),
        'pin' => _ActionSpec(OverdriveEndpoints.findCar, const {}),
        _ => null,
      };
}

class _ActionSpec {
  const _ActionSpec(this.path, this.body);
  final String path;
  final Map<String, dynamic> body;
}

String? _optionalStr(Object? raw) {
  final s = raw?.toString().trim() ?? '';
  return s.isEmpty ? null : s;
}

/// Test-only: hydrate from bundled fixture JSON string.
void applyFixtureJson(RealVehicleRepository repo, String jsonText) {
  final map = jsonDecode(jsonText) as Map<String, dynamic>;
  repo.applyVehicleStateJson(map);
}
