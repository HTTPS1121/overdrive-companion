import 'dart:math';

/// Extended HTTP routes for automations, parking, trips, audio, telegram, GenAI tools, platform APIs.
class MockExtendedBackend {
  MockExtendedBackend() {
    _automations = [
      {'id': 'auto-1', 'name': 'Arrive home climate', 'mode': 'automatic', 'enabled': true},
      {'id': 'auto-2', 'name': 'Night charge cap', 'mode': 'manual', 'enabled': false},
    ];
    _parkingSessions = [
      {
        'id': 'park-1',
        'startedAt': '2025-11-07T18:00:00Z',
        'endedAt': '2025-11-07T20:15:00Z',
        'place': 'Mall',
      },
    ];
    _trips = [
      {'id': 'trip-1', 'label': 'Commute', 'distanceKm': 24.5, 'startedAt': '2025-11-07T07:30:00Z'},
    ];
    _audioLibrary = [
      {'name': 'welcome_chime.wav', 'size': 48000},
      {'name': 'lock_beep.wav', 'size': 12000},
    ];
  }

  late List<Map<String, dynamic>> _automations;
  late List<Map<String, dynamic>> _parkingSessions;
  late List<Map<String, dynamic>> _trips;
  late List<Map<String, dynamic>> _audioLibrary;

  bool parkingEnabled = true;
  bool telegramPaired = true;
  bool telegramVideoUploads = false;
  bool genAiRoutinesEnabled = true;

  Map<String, dynamic>? tryGet(String path) {
    final base = path.split('?').first;
    switch (base) {
      case '/api/automations/list':
        return {'success': true, 'automations': _automations};
      case '/api/automations/schema':
        return {
          'success': true,
          'schemaVersion': 1,
          'signals': ['battery.soc', 'doors.overall'],
        };
      case '/api/parking/status':
        return {
          'success': true,
          'enabled': parkingEnabled,
          'openSession': null,
          'latestSession': _parkingSessions.first,
        };
      case '/api/parking/config':
        return {'success': true, 'enabled': parkingEnabled};
      case '/api/parking/sessions':
        return {'success': true, 'sessions': _parkingSessions};
      case '/api/trips/summary':
        return {'success': true, 'totalKm': 120.4, 'tripCount': _trips.length};
      case '/api/trips':
        return {'success': true, 'trips': _trips};
      case '/api/trips/config':
        return {'success': true, 'enabled': true};
      case '/api/audio/library':
        return {'success': true, 'library': _audioLibrary};
      case '/api/audio/avas-state':
        return {'success': true, 'playing': false};
      case '/api/telegram/status':
        return {
          'success': true,
          'configured': true,
          'paired': telegramPaired,
          'botUsername': 'overdrive_mock_bot',
          'videoUploads': telegramVideoUploads,
        };
      case '/api/genai/routines':
        return {
          'success': true,
          'enabled': genAiRoutinesEnabled,
          'suggestions': [
            {'id': 'r1', 'title': 'Pre-cool before commute'},
          ],
        };
      case '/api/genai/incidents':
        return {
          'success': true,
          'packs': [
            {'id': 'inc-1', 'title': 'Close pass', 'createdAt': '2025-11-06'},
          ],
        };
      case '/api/abrp/status':
        return {'success': true, 'linked': true, 'routeActive': false};
      case '/api/abrp/config':
        return {'success': true, 'tokenPresent': true, 'mirrorSoc': true, 'enabled': true};
      case '/api/abrp/token':
        return {'success': true};
      case '/api/mqtt/status':
        return {'success': true, 'connected': 1, 'total': 1};
      case '/api/mqtt/connections':
        return {
          'success': true,
          'connections': [
            {'id': 'mqtt-1', 'name': 'Home', 'enabled': true},
          ],
        };
      case '/api/mqtt/telemetry':
        return {'success': true, 'soc': 72, 'timestamp': 1730000000};
      case '/api/launcher/v1/summary':
        return {'success': true, 'vehicle': {'model': 'Atto 3'}, 'charging': {'plugged': false}};
      case '/api/launcher/v1/appearance':
        return {'success': true, 'theme': 'dark', 'locale': 'he-IL'};
      case '/api/roadsense/hazards':
        return {
          'type': 'FeatureCollection',
          'features': [
            {
              'type': 'Feature',
              'properties': {'id': 'h1', 'kind': 'pothole'},
              'geometry': {'type': 'Point', 'coordinates': [34.78, 32.08]},
            },
          ],
        };
      case '/api/bydcloud/status':
        return {'success': true, 'configured': false, 'loggedIn': false};
      case '/api/community/list':
        return {
          'success': true,
          'items': [
            {'id': 'c1', 'name': 'Seat heat on unlock', 'stars': 4.5},
          ],
          'page': 1,
        };
      case '/api/debug/seat/read':
        return {
          'success': true,
          'group': 'all',
          'registers': {'driver_vent': 2, 'passenger_heat': 0},
        };
      case '/api/logs/available':
        return {
          'available': true,
          'daemons': ['overdrive', 'roadsense'],
        };
      case '/api/debug/car-property/status':
        return {'success': true, 'ready': true, 'apiLevel': 33};
      case '/api/debug/car-property/get':
        return {'success': true, 'key': '0x11400008', 'value': 42, 'type': 'int32'};
      case '/api/debug/adas/resolve':
        return {'success': true, 'stack': 'mock_adas_v1'};
      case '/api/debug/adas/read':
        return {'success': true, 'registers': {'laneAssist': true}};
      case '/api/debug/light/resolve':
        return {'success': true, 'zones': ['ambient', 'reading']};
      case '/api/debug/remote-key':
        return {'success': true, 'pairedKeys': 1, 'lastEvent': 'lock'};
      case '/api/debug/autoservice/status':
        return {'success': true, 'status': 'idle', 'queueDepth': 0};
      default:
        if (base.startsWith('/api/trips/') && base != '/api/trips/config') {
          return {'success': true, 'id': base.split('/').last, 'distanceKm': 24.5};
        }
        return null;
    }
  }

  Map<String, dynamic>? tryPost(String path, Map<String, dynamic> body) {
    final base = path.split('?').first;
    switch (base) {
      case '/api/automations/automation':
        final id = 'auto-${Random().nextInt(9000) + 1000}';
        final name = body['name']?.toString() ?? 'New automation';
        _automations.add({'id': id, 'name': name, 'enabled': body['enabled'] == true, 'mode': 'manual'});
        return {'success': true, 'id': id};
      case '/api/parking/config':
        parkingEnabled = body['enabled'] == true;
        return {'success': true, 'enabled': parkingEnabled};
      case '/api/audio/library/play':
        return {'success': true, 'playing': body['name']};
      case '/api/audio/library/stop':
        return {'success': true, 'playing': false};
      case '/api/telegram/preferences':
        if (body.containsKey('videoUploads')) {
          telegramVideoUploads = body['videoUploads'] == true;
        }
        return {'success': true, 'videoUploads': telegramVideoUploads};
      case '/api/telegram/owner/clear':
      case '/api/telegram/clear':
        telegramPaired = false;
        return {'success': true};
      case '/api/genai/routines/config':
        genAiRoutinesEnabled = body['enabled'] == true;
        return {'success': true, 'enabled': genAiRoutinesEnabled};
      case '/api/genai/routines/decision':
        return {'success': true, 'decision': body['decision']};
      case '/api/genai/routines/reset':
        return {'success': true};
      case '/api/genai/incidents':
        return {
          'success': true,
          'id': 'inc-new',
          'title': 'Draft pack',
          'recordingId': body['recordingId'],
        };
      case '/api/genai/action/execute':
        return {'success': true, 'outcome': 'mock_executed', 'action': body['action']};
      case '/api/abrp/config':
        return {'success': true, ...body};
      case '/api/mqtt/connections':
        return {'success': true, 'id': 'mqtt-new', ...body};
      case '/api/logs/upload':
        return {'success': true, 'code': 'mock-upload-7f3a'};
      case '/api/roadsense/delete-local':
        return {'success': true, 'deleted': 'local'};
      case '/api/roadsense/delete-cloud':
        return {'success': true, 'deleted': 'cloud'};
      case '/api/roadsense/test-chime':
        return {
          'success': true,
          'played': true,
          'severity': body['severity'],
          'channel': body['channel'],
          'volumePercent': body['volumePercent'],
        };
      default:
        if (base.startsWith('/api/automations/test/')) {
          return {'success': true, 'tested': base.split('/').last};
        }
        if (base.startsWith('/api/automations/mode/')) {
          final id = base.split('/').last;
          final mode = body['mode']?.toString() ?? 'automatic';
          for (final a in _automations) {
            if (a['id'] == id) a['mode'] = mode;
          }
          return {'success': true, 'mode': mode};
        }
        if (base.contains('/api/roadsense/hazard/') &&
            (base.endsWith('/confirm') || base.endsWith('/reject'))) {
          return {'success': true, 'hazardId': base.split('/')[4], 'verdict': base.split('/').last};
        }
        return null;
    }
  }

  Map<String, dynamic>? tryDelete(String path) {
    final base = path.split('?').first;
    if (base.startsWith('/api/automations/automation/')) {
      final id = base.substring('/api/automations/automation/'.length);
      _automations.removeWhere((e) => e['id'] == id);
      return {'success': true};
    }
    if (base.startsWith('/api/parking/sessions/')) {
      final id = base.substring('/api/parking/sessions/'.length);
      _parkingSessions.removeWhere((e) => e['id'] == id);
      return {'success': true};
    }
    if (base.startsWith('/api/trips/')) {
      final id = base.replaceFirst('/api/trips/', '');
      _trips.removeWhere((e) => e['id'] == id);
      return {'success': true};
    }
    if (base.startsWith('/api/mqtt/connections/')) {
      return {'success': true};
    }
    if (base.startsWith('/api/abrp/token')) {
      return {'success': true};
    }
    if (base.startsWith('/api/community/import/')) {
      return {'success': true, 'importedId': base.split('/').last};
    }
    return null;
  }

  Map<String, dynamic>? tryPut(String path, Map<String, dynamic> body) {
    if (path.startsWith('/api/mqtt/connections/')) {
      return {'success': true, ...body};
    }
    return null;
  }
}
