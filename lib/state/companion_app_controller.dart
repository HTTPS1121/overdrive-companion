import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:overdrive_server/overdrive_server.dart';

import '../data/hebrew_errors.dart';
import '../data/real_vehicle_repository.dart';
import '../data/secure_settings_store.dart';
import '../data/vehicle_repository.dart';
import '../models/companion_models.dart';
import '../models/connection_draft.dart';

final secureSettingsStoreProvider = Provider<SecureSettingsStore>((ref) {
  throw UnimplementedError('secureSettingsStoreProvider must be overridden');
});

final apiClientProvider = Provider<OverdriveApiClient>((ref) {
  final store = ref.watch(secureSettingsStoreProvider);
  return OverdriveApiClient(baseUrl: store.settingsSync.baseUrl, jwt: store.jwt);
});

final vehicleRepoProvider = Provider<VehicleRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  final repo = RealVehicleRepository(client);
  ref.listen(apiClientProvider, (prev, next) {
    if (prev != next) repo.updateClient(next);
  });
  return repo;
});

final companionAppControllerProvider =
    ChangeNotifierProvider<CompanionAppController>((ref) {
  return CompanionAppController(
    ref.watch(vehicleRepoProvider),
    ref.watch(secureSettingsStoreProvider),
    ref.watch(apiClientProvider),
  );
});

class RecFilters {
  String type = 'all';
  String cls = '';
  String sev = '';
  String prox = '';
  String stor = '';
  String place = '';
}

class SheetRequest {
  SheetRequest({required this.title, required this.body});

  final String title;
  final WidgetBuilder body;
}

class CompanionAppController extends ChangeNotifier {
  CompanionAppController(
    this._repo,
    this._settings,
    this._client, {
    bool skipBootstrap = false,
  }) {
    if (!skipBootstrap) {
      Future.microtask(_bootstrapSavedSession);
    }
  }

  final VehicleRepository _repo;
  final SecureSettingsStore _settings;
  final OverdriveApiClient _client;

  bool loginVisible = true;
  OdScreen screen = OdScreen.home;
  bool connecting = false;
  bool testingConnection = false;
  String? loginErrorHebrew;
  String? connectionTestHebrew;
  bool connectionTestOk = false;

  bool get locked => _repo.locked;
  bool get powered => _repo.powered;
  bool get trunkOpen => _repo.trunkOpen;

  int camSel = 0;
  bool camModeAll = false;
  bool camMapExpanded = false;

  final RecFilters recFilters = RecFilters();
  int? recPlayId;
  int recPlayQuad = 0;
  int recPlaySeconds = 0;

  SheetRequest? sheet;
  bool get sheetOpen => sheet != null;

  static const cams = ['חזית', 'אחור', 'צד שמאל', 'צד ימין'];

  ConnectionDraft get savedConnectionDraft => ConnectionDraft(
        mode: _settings.connectionMode,
        address: _settings.settingsSync.baseUrl,
        deviceId: _settings.settingsSync.deviceId,
        accessCode: _settings.settingsSync.accessCode,
      );

  String parkLine() {
    final p = powered ? 'פועל · בחניה' : 'כבוי · חונה';
    final l = locked ? 'נעול' : 'לא נעול';
    final t = trunkOpen ? ' · תא מטען פתוח' : '';
    return '$p · $l$t';
  }

  Future<void> _bootstrapSavedSession() async {
    final jwt = _settings.jwt;
    if (!_settings.settingsSync.isConfigured || jwt == null) return;
    _client.jwt = jwt;
    loginVisible = false;
    await _refreshAfterLogin();
  }

  @visibleForTesting
  void debugEnterSignedIn() {
    loginVisible = false;
    notifyListeners();
  }

  String? _validateDraft(ConnectionDraft draft) {
    final baseUrl = normalizeBaseUrl(draft.address);
    if (baseUrl.isEmpty) return 'הזן כתובת שרת.';
    if (draft.mode == CompanionConnectionMode.local && !isLocalHttpUrl(baseUrl)) {
      return 'ברשת מקומית יש להשתמש בכתובת http:// (למשל http://192.168.0.12:8080).';
    }
    if (draft.mode == CompanionConnectionMode.tunnel && !baseUrl.startsWith('https://')) {
      return 'במנהרה מרוחקת יש להשתמש בכתובת https://.';
    }
    if (draft.accessCode.trim().length < 8) {
      return 'קוד גישה קצר מדי (מינימום 8 תווים).';
    }
    return null;
  }

  void clearLoginFeedback() {
    connectionTestHebrew = null;
    connectionTestOk = false;
    loginErrorHebrew = null;
    notifyListeners();
  }

  Future<void> testConnection(ConnectionDraft draft) async {
    connectionTestHebrew = null;
    connectionTestOk = false;
    loginErrorHebrew = null;
    final validation = _validateDraft(draft);
    if (validation != null) {
      connectionTestHebrew = validation;
      notifyListeners();
      return;
    }
    testingConnection = true;
    notifyListeners();
    try {
      final baseUrl = normalizeBaseUrl(draft.address);
      _client.baseUrl = baseUrl;
      _client.jwt = null;
      final status = await _client.fetchAuthStatus().timeout(const Duration(seconds: 20));
      if (!status.ok) {
        connectionTestHebrew = hebrewServerUnsupported();
        return;
      }
      final resolvedId =
          draft.deviceId.trim().isNotEmpty ? draft.deviceId.trim() : (status.deviceId ?? '');
      final authProbe = resolvedId.isNotEmpty ? ' · מזהה: $resolvedId' : '';
      connectionTestOk = true;
      connectionTestHebrew = 'החיבור תקין. השרת מגיב לבקשת סטטוס$authProbe.';
      await _settings.saveConnectionDraft(
        mode: draft.mode,
        baseUrl: baseUrl,
        deviceId: resolvedId,
        accessCode: draft.accessCode.trim(),
      );
    } on TimeoutException {
      connectionTestHebrew = hebrewForTimeout();
    } on OverdriveApiException catch (e) {
      connectionTestHebrew = hebrewApiException(e);
    } catch (_) {
      connectionTestHebrew = hebrewForOffline();
    } finally {
      testingConnection = false;
      notifyListeners();
    }
  }

  Future<void> connect(ConnectionDraft draft) async {
    clearLoginFeedback();
    final validation = _validateDraft(draft);
    if (validation != null) {
      loginErrorHebrew = validation;
      notifyListeners();
      return;
    }
    connecting = true;
    notifyListeners();
    try {
      final baseUrl = normalizeBaseUrl(draft.address);
      _client.baseUrl = baseUrl;
      _client.jwt = null;
      final status = await _client.fetchAuthStatus().timeout(const Duration(seconds: 25));
      if (!status.ok) {
        loginErrorHebrew = hebrewServerUnsupported();
        return;
      }
      final resolvedId =
          draft.deviceId.trim().isNotEmpty ? draft.deviceId.trim() : (status.deviceId ?? '');
      if (resolvedId.isEmpty) {
        loginErrorHebrew = 'חסר מזהה מכשיר. נסה «בדיקת חיבור» או העתק מהאפליקציה ברכב.';
        return;
      }
      await _client
          .loginWithAccessCode(deviceId: resolvedId, accessCode: draft.accessCode.trim())
          .timeout(const Duration(seconds: 25));
      final sessionJwt = _client.jwt;
      if (sessionJwt == null || sessionJwt.isEmpty) {
        loginErrorHebrew = hebrewAuthDenied();
        return;
      }
      final sessionSettings = AppSettings(
        baseUrl: baseUrl,
        deviceId: resolvedId,
        accessCode: draft.accessCode.trim(),
      );
      await _settings.saveSession(
        mode: draft.mode,
        sessionSettings: sessionSettings,
        sessionJwt: sessionJwt,
      );
      loginVisible = false;
      if (sheetOpen) closeSheet();
      await _refreshAfterLogin();
    } on TimeoutException {
      loginErrorHebrew = hebrewForTimeout();
    } on OverdriveApiException catch (e) {
      loginErrorHebrew = hebrewApiException(e);
    } catch (e) {
      loginErrorHebrew = hebrewForOffline();
    } finally {
      connecting = false;
      notifyListeners();
    }
  }

  Future<void> _refreshAfterLogin() async {
    await _repo.refreshVehicleState();
    await _repo.refreshRecordings();
    await _repo.refreshStreamStatus();
    await _repo.refreshTrips();
    notifyListeners();
  }

  Future<void> refreshAll() async {
    _dismissTransientUi();
    await _repo.refreshVehicleState();
    await _repo.refreshRecordings();
    await _repo.refreshStreamStatus();
    await _repo.refreshTrips();
    notifyListeners();
  }

  void _dismissTransientUi() {
    closeSheet();
    closeRecordingPlayer();
  }

  Future<void> logout() async {
    closeSheet();
    await _settings.clearSession();
    _client.jwt = null;
    _client.baseUrl = '';
    loginVisible = true;
    notifyListeners();
  }

  void exitToLogin() => unawaited(logout());

  void setScreen(OdScreen s) {
    screen = s;
    if (s != OdScreen.camera) camMapExpanded = false;
    if (s == OdScreen.record && !_repo.recordingsKnown) {
      unawaited(_repo.refreshRecordings().then((_) => notifyListeners()));
    }
    if (s == OdScreen.camera && !_repo.streamKnown) {
      unawaited(_repo.refreshStreamStatus().then((_) => notifyListeners()));
    }
    if (s == OdScreen.trip && !_repo.tripsKnown) {
      unawaited(_repo.refreshTrips().then((_) => notifyListeners()));
    }
    notifyListeners();
  }

  void openSheet(String title, WidgetBuilder body) {
    sheet = SheetRequest(title: title, body: body);
    notifyListeners();
  }

  void closeSheet() {
    sheet = null;
    notifyListeners();
  }

  void openRecordingPlayer(int id) {
    recPlayId = id;
    recPlayQuad = 0;
    recPlaySeconds = 0;
    notifyListeners();
  }

  void closeRecordingPlayer() {
    recPlayId = null;
    notifyListeners();
  }

  void setRecPlayQuad(int index) {
    recPlayQuad = index;
    notifyListeners();
  }

  void selectOdCamHotspot(int id) {
    if (id == 0) {
      camModeAll = true;
    } else if (id == 6) {
      return;
    } else {
      const map = {1: 0, 2: 3, 3: 1, 4: 2};
      final idx = map[id];
      if (idx == null) return;
      camModeAll = false;
      camSel = idx;
    }
    notifyListeners();
  }

  bool odCamHotspotActive(int id) {
    if (id == 0) return camModeAll;
    const map = {1: 0, 2: 3, 3: 1, 4: 2};
    final idx = map[id];
    if (idx == null) return false;
    return !camModeAll && camSel == idx;
  }

  Future<CommandResult> confirmAction(String id) async {
    final result = await _repo.runCompanionAction(id);
    notifyListeners();
    return result;
  }

  Future<CommandResult> confirmServerControl(ControlKind kind) async {
    final result = await _repo.runServerControl(kind);
    notifyListeners();
    return result;
  }

  List<TripSummary> get todayTrips {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    return trips.where((t) {
      final started = DateTime.fromMillisecondsSinceEpoch(t.startTimeMs);
      return !started.isBefore(start);
    }).toList();
  }

  List<Recording> filteredRecordings() {
    return _repo.recordings.where((r) {
      if (recFilters.type != 'all' && r.type.name != recFilters.type) {
        return false;
      }
      if (recFilters.cls.isNotEmpty && r.actor != recFilters.cls) return false;
      if (recFilters.sev.isNotEmpty && r.sev != recFilters.sev) return false;
      if (recFilters.prox.isNotEmpty && r.prox != recFilters.prox) return false;
      if (recFilters.stor.isNotEmpty && r.storage != recFilters.stor) {
        return false;
      }
      if (recFilters.place.isNotEmpty && r.shortPlace != recFilters.place) {
        return false;
      }
      return true;
    }).toList();
  }

  void setRecFilter(String key, String value) {
    switch (key) {
      case 'type':
        recFilters.type = value;
      case 'cls':
        recFilters.cls = value;
      case 'sev':
        recFilters.sev = value;
      case 'prox':
        recFilters.prox = value;
      case 'stor':
        recFilters.stor = value;
      case 'place':
        recFilters.place = value;
    }
    notifyListeners();
  }

  int get rangeKm => _repo.rangeKm;
  int get batteryPercent => _repo.batteryPercent;
  String get carName => _repo.carName;
  String get carTrim => _repo.carTrim;
  String get refreshLabel => _repo.refreshLabel;
  bool get vehicleStateStale => _repo.vehicleStateStale;
  String? get vehicleOfflineHebrew => _repo.vehicleOfflineHebrew;

  DataLoadState get recordingsState => _repo.recordingsState;
  String? get recordingsErrorHebrew => _repo.recordingsErrorHebrew;

  DataLoadState get streamState => _repo.streamState;
  String? get streamErrorHebrew => _repo.streamErrorHebrew;

  DataLoadState get tripsState => _repo.tripsState;
  String? get tripsErrorHebrew => _repo.tripsErrorHebrew;
  List<TripSummary> get trips => _repo.trips;

  VehicleStatusSnapshot get vehicleStatus => _repo.vehicleStatus;

  RecordingStatsSnapshot get recordingStats => _repo.recordingStats;
}
