import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../demo/demo_models.dart';
import '../demo/demo_repository.dart';

final demoRepoProvider = Provider<VehicleRepository>((ref) {
  return DemoVehicleRepository();
});

final demoAppControllerProvider =
    ChangeNotifierProvider<DemoAppController>((ref) {
  return DemoAppController(ref.watch(demoRepoProvider));
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

class DemoAppController extends ChangeNotifier {
  DemoAppController(this._repo);

  final VehicleRepository _repo;

  bool loginVisible = true;
  OdScreen screen = OdScreen.home;

  bool get locked => _repo.locked;
  bool get powered => _repo.powered;
  bool get trunkOpen => _repo.trunkOpen;

  int camSel = 0;
  bool camModeAll = false;
  bool camMapExpanded = false;

  final RecFilters recFilters = RecFilters();
  int? recPlayId;
  int recPlayQuad = 0;
  int recPlaySeconds = 2;

  SheetRequest? sheet;
  bool get sheetOpen => sheet != null;

  static const cams = ['חזית', 'אחור', 'צד שמאל', 'צד ימין'];

  String parkLine() {
    final p = powered ? 'פועל · בחניה' : 'כבוי · חונה';
    final l = locked ? 'נעול' : 'לא נעול';
    final t = trunkOpen ? ' · תא מטען פתוח' : '';
    return '$p · $l$t';
  }

  void enterDemo() {
    loginVisible = false;
    notifyListeners();
  }

  void exitToLogin() {
    closeSheet();
    loginVisible = true;
    notifyListeners();
  }

  void setScreen(OdScreen s) {
    screen = s;
    if (s != OdScreen.camera) camMapExpanded = false;
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
    recPlaySeconds = 2;
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

  /// Hotspot ids from HTML `data-od-cam` (1 front, 3 rear, 4 left, 2 right, 0 all, 6 DVR).
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

  Future<void> confirmAction(String id) async {
    switch (id) {
      case 'lock':
        await _repo.setLocked(true);
      case 'unlock':
        await _repo.setLocked(false);
      case 'power':
        await _repo.setPowered(true);
      case 'off':
        await _repo.setPowered(false);
      case 'trunk':
        await _repo.setTrunkOpen(true);
      case 'down':
        await _repo.setTrunkOpen(false);
    }
    notifyListeners();
  }

  List<DemoRecording> filteredRecordings() {
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
}
