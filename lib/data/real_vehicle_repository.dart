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

  @override
  List<Recording> get recordings => List.unmodifiable(_recordings);

  @override
  List<String> get placeFilters => List.unmodifiable(_placeFilters);

  @override
  List<TripSummary> get trips => List.unmodifiable(_trips);

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
        ),
      );
    }
    return out;
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
