import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:overdrive_companion/data/models/cloud_status.dart';
import 'package:overdrive_companion/data/models/gps_snapshot.dart';
import 'package:overdrive_companion/data/models/vehicle_state.dart';

import 'mock_extended_backend.dart';

/// In-memory simulation of Overdrive HTTP handlers (vehicle state + controls).
class MockOverdriveBackend {
  MockOverdriveBackend({Map<String, dynamic>? initialState})
      : _state = Map<String, dynamic>.from(initialState ?? _defaultState()),
        _climateBookings = List<Map<String, dynamic>>.from(_defaultClimateBookings());

  final Map<String, dynamic> _state;
  final List<Map<String, dynamic>> _climateBookings;
  int _chargeCapPercent = 100;
  bool _chargeCapEnabled = false;
  int _acChargeCurrentState = 3;
  bool _acChargeCurrentSupported = true;
  bool _acChargeCurrentAvailable = true;

  static const _acChargeLabels = {
    1: '6A',
    2: '8A',
    3: '10A',
    4: '13A',
    5: '16A',
  };
  String? _jwt;
  bool authRequired = false;
  bool _wireguardExpose = false;
  bool _wireguardConfigured = true;
  String _wireguardConfigText = '[Interface]\n# mock';
  bool _genaiEnabled = true;
  bool _communicateVoice = true;
  bool _communicateMessages = true;
  bool _communicateListener = true;
  int _communicateOutputLevel = 70;
  final MockExtendedBackend _extended = MockExtendedBackend();

  void configureRemoteServicesFixture({
    bool communicateVoice = true,
    bool communicateListener = true,
    bool genAiEnabled = true,
  }) {
    _communicateVoice = communicateVoice;
    _communicateListener = communicateListener;
    _genaiEnabled = genAiEnabled;
  }

  static Map<String, dynamic> _defaultState() => {
        'success': true,
        'doors': {
          'lf': 1,
          'rf': 1,
          'lr': 1,
          'rr': 1,
          'trunk': 1,
          'overall': 1,
          'scope': 'vehicle',
          'source': 'mock',
        },
        'doorOpen': {'lf': false, 'rf': false, 'lr': false, 'rr': false, 'trunk': false},
        'windows': {'lf': 0, 'rf': 0, 'lr': 0, 'rr': 0, 'sunroof': 0},
        'windowOpen': {'lf': false, 'rf': false, 'lr': false, 'rr': false},
        'battery': {'soc': 72, 'rangeKm': 280, 'bodyworkRangeKm': 278},
        'climate': {
          'acOn': false,
          'insideTempC': 23.0,
          'fanLevel': 2,
          'setpointDriver': 22.0,
        },
        'seats': {'heat': [0, 0], 'steeringHeat': false},
        'lights': {'readingLight': false},
        'tyres': {
          'available': true,
          'fl': {'kPa': 250, 'psi': 36.3, 'temperatureC': 26, 'available': true},
          'fr': {'kPa': 249, 'psi': 36.1, 'temperatureC': 26, 'available': true},
          'rl': {'kPa': 251, 'psi': 36.4, 'temperatureC': 25, 'available': true},
          'rr': {'kPa': 250, 'psi': 36.3, 'temperatureC': 25, 'available': true},
        },
        'timestamp': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'batteryHeat': false,
      };

  static Future<MockOverdriveBackend> fromFixture() async {
    final raw = await rootBundle.loadString('fixtures/vehicle_state_sample.json');
    return MockOverdriveBackend(initialState: jsonDecode(raw) as Map<String, dynamic>);
  }

  Map<String, dynamic> authStatus() => {
        'status': 'ok',
        'success': true,
        'deviceId': 'mock-atto3-demo',
        'authRequired': authRequired,
      };

  Map<String, dynamic> login(String token) {
    const deviceId = 'mock-atto3-demo';
    if (authRequired && token != 'mock-device-token') {
      const allowedCodes = {'validcode1', 'testcode99'};
      final suffix =
          token.startsWith('$deviceId-') ? token.substring(deviceId.length + 1) : '';
      if (!allowedCodes.contains(suffix)) {
        return {'success': false, 'error': 'invalid device token'};
      }
    }
    _jwt = 'mock.jwt.$token';
    return {
      'success': true,
      'jwt': _jwt,
      'token': _jwt,
      'deviceId': 'mock-atto3-demo',
      'expiresIn': 86400,
    };
  }

  bool authorize(String? bearer) {
    if (!authRequired) return true;
    if (bearer == null || bearer.isEmpty) return false;
    return bearer == _jwt;
  }

  Map<String, dynamic> vehicleState() {
    _state['timestamp'] = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return Map<String, dynamic>.from(_state);
  }

  VehicleState parseVehicleState() => VehicleState.fromJson(vehicleState());

  CloudStatus cloudStatus() => const CloudStatus(
        success: true,
        configured: true,
        verified: true,
        enabled: true,
        localRemoteKey: true,
      );

  static List<Map<String, dynamic>> _defaultClimateBookings() {
    // Epoch seconds (UTC): 2025-01-06 08:00 → 10:00 Asia/Jerusalem (UTC+2)
    const t1 = 1736150400;
    // 2025-01-07 08:00 UTC
    const t2 = 1736236800;
    return [
      {
        'bookingId': '8844123456789012',
        'bookingTime': t1,
        'mainSettingTemp': 8,
        'timeSpan': 3,
      },
      {
        'bookingId': '8844987654321098',
        'bookingTime': t2,
        'mainSettingTemp': 6,
        'timeSpan': 2,
      },
    ];
  }

  GpsSnapshot gps() => const GpsSnapshot(
        success: true,
        latitude: 32.0853,
        longitude: 34.7818,
        canSpeedKmh: 0,
      );

  Map<String, dynamic> handlePost(String path, Map<String, dynamic> body) {
    switch (path) {
      case '/api/vehicle/lock':
        _setOverallLock(locked: true);
        return _ok('lock', message: 'נעילה אושרה (סימולציה)', confirmation: 'local');
      case '/api/vehicle/unlock':
        _setOverallLock(locked: false);
        return _ok('unlock', message: 'פתיחה אושרה (סימולציה)', confirmation: 'local');
      case '/api/vehicle/trunk':
        final action = body['action'] as String? ?? 'open';
        final open = action == 'open';
        _state['doorOpen'] = {..._map('doorOpen'), 'trunk': open};
        return _ok('trunk', message: open ? 'trunk opened' : 'trunk closed');
      case '/api/vehicle/window':
        return _handleWindow(body);
      case '/api/vehicle/flash':
        return _ok('flash', message: 'lights flashed');
      case '/api/vehicle/climate':
        return _handleClimate(body);
      case '/api/vehicle/lights':
        return _handleLights(body);
      case '/api/vehicle/find-car':
        return _ok('find-car', message: 'find-car');
      case '/api/vehicle/seat':
        return _handleSeat(body);
      case '/api/vehicle/media':
        return _ok('media', message: body['target']?.toString());
      case '/api/vehicle/adas':
        return _ok('adas', message: body['target']?.toString());
      case '/api/vehicle/setting':
        return _ok('setting');
      case '/api/vehicle/climate-schedule':
        return _handleClimateSchedule(body);
      case '/api/vehicle/charging-schedule':
        return _ok('charging-schedule');
      case '/api/vehicle/start-charging':
        return _ok('start-charging');
      case '/api/vehicle/charge-cap':
        return _handleChargeCapPost(body);
      case '/api/vehicle/power-on':
        return _handleVehiclePower(on: true);
      case '/api/vehicle/power-off':
        return _handleVehiclePower(on: false);
      case '/api/vehicle/battery-heat':
        final en = body['enabled'] == true;
        _state['batteryHeat'] = en;
        return {
          ..._ok('battery-heat', message: 'batteryHeat=$en', confirmation: 'local'),
          'enabled': en,
        };
      case '/api/vehicle/ac-charge-current-limit':
        return _handleAcChargeCurrentLimitPost(body);
      case '/api/stream/enable':
        return _ok('stream-enable');
      case '/api/stream/disable':
        return _ok('stream-disable');
      case '/api/stream/quality':
        return _ok('stream-quality', message: body['quality']?.toString());
      case '/api/surveillance/config':
        return _ok('surveillance-config');
      case '/api/surveillance/enable':
      case '/api/surveillance/disable':
        return _ok('surveillance-toggle');
      case '/api/surveillance/screen-deterrent/test':
        return {'success': true, 'status': 'queued'};
      case '/api/communicate/settings':
        if (body.containsKey('voiceEnabled')) {
          _communicateVoice = body['voiceEnabled'] == true;
        }
        if (body.containsKey('messagesEnabled')) {
          _communicateMessages = body['messagesEnabled'] == true;
        }
        if (body.containsKey('listenerEnabled')) {
          _communicateListener = body['listenerEnabled'] == true;
        }
        if (body['outputLevel'] is num) {
          _communicateOutputLevel = (body['outputLevel'] as num).toInt();
        }
        return communicateSettings();
      case '/api/communicate/message':
        final msg = body['message']?.toString() ?? body['text']?.toString() ?? '';
        return {
          'success': true,
          'status': 'displayed',
          'renderedKind': body['kind'] ?? 'toast',
          'message': msg,
        };
      case '/api/communicate/test-speaker':
        return {'success': true, 'status': 'queued'};
      case '/api/communicate/emergency-stop':
        return {'success': true, 'emergencyDisabled': true};
      case '/api/genai/chat':
        return {
          'success': _genaiEnabled,
          'reply': _genaiEnabled ? 'Mock GenAI reply' : null,
          if (!_genaiEnabled) 'error': 'genai_disabled',
        };
      case '/api/genai/test':
        return {'success': _genaiEnabled, 'status': 'ok'};
      case '/api/wireguard/config':
        final text = body['config']?.toString() ?? '';
        if (text.isEmpty) {
          return {'success': false, 'error': 'config required'};
        }
        _wireguardConfigText = text;
        _wireguardConfigured = true;
        return {'success': true, 'configured': true, 'peerCount': 1};
      case '/api/wireguard/expose':
        _wireguardExpose = body['enabled'] == true;
        return {'success': true, 'expose_dashboard': _wireguardExpose};
      case '/api/vehicle/system':
        if (body['target'] == 'screenshot') {
          final d = body['display'] ?? 0;
          return {
            'success': true,
            'target': 'screenshot',
            'path': '/storage/sdcard/OverDrive/screenshots/shot_d${d}_mock.png',
            'confirmation': 'local',
            'outcome': 'success',
          };
        }
        final target = body['target']?.toString() ?? '';
        if (['home', 'back', 'recents', 'move_display'].contains(target)) {
          return {'success': true, 'target': target, 'outcome': 'queued'};
        }
        return {'success': false, 'error': 'unsupported system target'};
      case '/api/vehicle/play-audio':
        return {'success': true, 'playing': body['file']};
      case '/api/vehicle/stop-audio':
        return {'success': true, 'playing': false};
      case '/api/vehicle/speak':
        return {'success': true, 'spoken': body['text']};
      case '/api/vehicle/message':
        return {'success': true, 'displayed': body['text']};
      case '/api/vehicle/cluster-cast':
        return {'success': true, 'action': body['action'] ?? 'start'};
      case '/api/vehicle/cluster-stop':
        return {'success': true, 'stopped': true};
      default:
        final ext = _extended.tryPost(path, body);
        if (ext != null) return ext;
        if (path.startsWith('/api/stream/view/')) {
          return _ok('stream-view');
        }
        return {'success': false, 'error': 'unsupported path $path'};
    }
  }

  Map<String, dynamic> handleDelete(String path) {
    final ext = _extended.tryDelete(path);
    if (ext != null) return ext;
    return {'success': false, 'error': 'unsupported DELETE $path'};
  }

  Map<String, dynamic> handlePut(String path, Map<String, dynamic> body) {
    final ext = _extended.tryPut(path, body);
    if (ext != null) return ext;
    return {'success': false, 'error': 'unsupported PUT $path'};
  }

  Map<String, dynamic> handleGet(String path) {
    final extGet = _extended.tryGet(path);
    if (extGet != null) return extGet;

    switch (path.split('?').first) {
      case '/api/vehicle/state':
        return vehicleState();
      case '/api/vehicle/climate-schedule':
        return {
          'success': true,
          'supported': true,
          'source': 'cloud',
          'emptyBookingsMayBeStale': true,
          'bookings': {
            'listInfo': _climateBookings,
          },
        };
      case '/api/vehicle/charging-schedule':
        return {
          'success': true,
          'supported': true,
          'enabled': false,
          'startChargeTime': '22:00',
          'endChargeTime': '06:00',
          'chargeWay': 'e',
          'source': 'cache',
        };
      case '/api/vehicle/adas':
        return {
          'success': true,
          'esp': {'raw': 0, 'on': true},
          'itac': {'raw': 0, 'on': false},
        };
      case '/api/vehicle/charge-cap':
        return {
          'success': true,
          'supported': true,
          'percent': _chargeCapPercent,
          'enabled': _chargeCapEnabled,
        };
      case '/api/vehicle/ac-charge-current-limit':
        return _acChargeCurrentGet();
      case '/api/vehicle/cluster-apps':
        return {
          'success': true,
          'apps': [
            {'package': 'com.android.car.cluster', 'label': 'Cluster'},
            {'package': 'com.byd.media', 'label': 'Media'},
          ],
        };
      case '/api/stream/status':
        return {
          'success': true,
          'enabled': true,
          'connected': true,
          'view': 0,
          'quality': 'HIGH',
        };
      case '/api/recordings':
        return {
          'success': true,
          'recordings': [
            {
              'id': 'a1b2c3d4e5f6789012345678abcdef01',
              'filename': '2025-11-07_12-30-00_front.mp4',
              'place': 'front',
              'timestamp': '1730986200',
              'sizeBytes': 12_000_000,
            },
          ],
        };
      case '/api/surveillance/status':
        return {'success': true, 'enabled': false};
      case '/api/surveillance/config':
        return {
          'success': true,
          'enabled': false,
          'sensitivity': 3,
          'distance': 3,
        };
      case '/api/surveillance/heatmap':
        return {
          'viewMode': 0,
          'gridCols': 8,
          'gridRows': 4,
          'blockSize': 32,
          'quadrants': [
            {
              'id': 0,
              'name': 'front',
              'enabled': true,
              'activeBlocks': 2,
              'threatLevel': 1,
              'confidence': [0.0, 0.1, 0.2, 0.4],
            },
            {
              'id': 2,
              'name': 'rear',
              'enabled': true,
              'activeBlocks': 0,
              'threatLevel': 0,
              'confidence': [0.0, 0.0],
            },
          ],
        };
      case '/api/surveillance/filterlog':
        return {
          'entries': ['q0 brightness suppress=false', 'q2 motion confirm=true'],
          'count': 2,
        };
      case '/api/communicate/status':
        return {
          'success': true,
          'reachable': true,
          'online': true,
          'carState': 'on',
          'busy': false,
          'audioReady': _communicateVoice,
          'messagesReady': _communicateMessages,
          'listenerReady': _communicateListener,
          'audioState': _communicateVoice ? 'ready' : 'disabled',
          'messageState': _communicateMessages ? 'ready' : 'disabled',
          'listenerState': _communicateListener ? 'ready' : 'disabled',
          'maxMessageChars': 200,
          'maxSeconds': 30,
        };
      case '/api/communicate/settings':
        return communicateSettings();
      case '/api/genai/status':
      case '/api/genai/config':
        return {
          'success': true,
          'enabled': _genaiEnabled,
          'model': 'mock-model',
          'configured': _genaiEnabled,
          'provider': 'mock',
        };
      case '/api/genai/insights':
        return {
          'success': true,
          'items': [
            {'id': '1', 'title': 'Battery trend', 'createdAt': 1730000000},
          ],
        };
      case '/api/genai/insights/dashboard':
        return {
          'success': true,
          'tiles': [
            {'id': 'battery', 'title': 'Battery insight'},
          ],
        };
      case '/api/wireguard':
        return wireguardStatus();
      default:
        final ext = _extended.tryGet(path);
        if (ext != null) return ext;
        if (path.startsWith('/api/surveillance/snapshot/')) {
          return {'success': false, 'error': 'use binary fixture via getBytes'};
        }
        return {'success': false, 'error': 'unsupported GET $path'};
    }
  }

  Map<String, dynamic> communicateSettings() => {
        'success': true,
        'voiceEnabled': _communicateVoice,
        'messagesEnabled': _communicateMessages,
        'listenerEnabled': _communicateListener,
        'outputLevel': _communicateOutputLevel,
        'outputLevelOverrideEnabled': false,
        'emergencyDisabled': false,
      };

  Map<String, dynamic> wireguardStatus() => {
        'configured': _wireguardConfigured,
        'running': false,
        'summary': _wireguardConfigured ? 'mock-peer' : '',
        'expose_dashboard': _wireguardExpose,
      };

  Map<String, dynamic> deleteWireGuardConfig() {
    _wireguardConfigured = false;
    _wireguardConfigText = '';
    return {'success': true};
  }

  List<int> screenDeterrentJpeg() => [
        0xFF,
        0xD8,
        0xFF,
        0xD9,
      ];

  Map<String, dynamic> _handleWindow(Map<String, dynamic> body) {
    if (body['action'] == 'vent') {
      _setAllWindows(25);
      return _ok('window', message: 'vent');
    }
    final command = body['command'];
    if (command == 1) {
      _setAllWindows(100);
      return _ok('window', message: 'windows open');
    }
    if (command == 2) {
      _setAllWindows(0);
      return _ok('window', message: 'windows closed');
    }
    return {'success': false, 'error': 'invalid window body'};
  }

  void _setAllWindows(int pct) {
    _state['windows'] = {'lf': pct, 'rf': pct, 'lr': pct, 'rr': pct, 'sunroof': pct};
    final open = pct > 0;
    _state['windowOpen'] = {
      'lf': open,
      'rf': open,
      'lr': open,
      'rr': open,
      'sunroof': open,
    };
  }

  Map<String, dynamic> _handleClimate(Map<String, dynamic> body) {
    final action = body['action'] as String? ?? '';
    final climate = _map('climate');
    switch (action) {
      case 'power_on':
        climate['acOn'] = true;
        if (body['temp'] != null) {
          climate['setpointDriver'] = (body['temp'] as num).toDouble();
        }
        break;
      case 'power_off':
        climate['acOn'] = false;
        break;
      case 'set_temp':
        climate['setpointDriver'] = (body['temp'] as num?)?.toDouble() ?? 22.0;
        break;
      case 'set_fan':
        climate['fanLevel'] = (body['fan'] as num?)?.toInt() ?? 2;
        break;
      case 'steering_heat_on':
        final seats = _map('seats');
        seats['steeringHeat'] = true;
        _state['seats'] = seats;
        break;
      case 'steering_heat_off':
        final seats = _map('seats');
        seats['steeringHeat'] = false;
        _state['seats'] = seats;
        break;
      default:
        return {'success': false, 'error': 'unknown climate action'};
    }
    _state['climate'] = climate;
    return _ok('climate', message: action);
  }

  Map<String, dynamic> _handleSeat(Map<String, dynamic> body) {
    final seats = _map('seats');
    final heat = List<int>.from((seats['heat'] as List?)?.map((e) => (e as num).toInt()) ?? [0, 0]);
    final cool = List<int>.from((seats['cool'] as List?)?.map((e) => (e as num).toInt()) ?? [0, 0]);
    if (body['driverHeat'] != null) heat[0] = (body['driverHeat'] as num).toInt();
    if (body['passengerHeat'] != null) heat[1] = (body['passengerHeat'] as num).toInt();
    if (body['driverVent'] != null) cool[0] = (body['driverVent'] as num).toInt();
    if (body['passengerVent'] != null) cool[1] = (body['passengerVent'] as num).toInt();
    if (body['level'] != null) {
      final pos = (body['position'] as num?)?.toInt() ?? 1;
      final level = (body['level'] as num).toInt();
      final action = body['action'] as String? ?? '';
      final idx = pos - 1;
      if (action == 'heating') heat[idx] = level;
      if (action == 'ventilation') cool[idx] = level;
    }
    seats['heat'] = heat;
    seats['cool'] = cool;
    _state['seats'] = seats;
    return _ok('seat', message: body['action']?.toString());
  }

  String? _bookingIdFromBody(Map<String, dynamic> body) {
    final raw = body['bookingId'];
    if (raw == null) return null;
    return raw.toString();
  }

  Map<String, dynamic> _handleClimateSchedule(Map<String, dynamic> body) {
    final action = body['action'] as String? ?? 'create';
    if (action == 'delete') {
      final id = _bookingIdFromBody(body);
      _climateBookings.removeWhere((b) => b['bookingId'] == id);
      return _ok('climate-schedule', message: 'deleted');
    }
    if (action == 'update') {
      final id = _bookingIdFromBody(body);
      final existing = _climateBookings.indexWhere((b) => b['bookingId'] == id);
      if (existing >= 0) {
        _climateBookings[existing] = {
          ..._climateBookings[existing],
          if (body['bookingTime'] != null) 'bookingTime': body['bookingTime'],
          if (body['temp'] != null) 'temp': body['temp'],
          if (body['durationMinutes'] != null) 'durationMinutes': body['durationMinutes'],
        };
      }
      return _ok('climate-schedule', message: 'updated');
    }
    final id = _bookingIdFromBody(body) ?? 'mock-climate-${_climateBookings.length + 1}';
    _climateBookings.add({
      'bookingId': id,
      'bookingTime': body['bookingTime'] ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'temp': body['temp'] ?? 22,
      'durationMinutes': body['durationMinutes'] ?? 20,
    });
    return _ok('climate-schedule', message: 'created');
  }

  Map<String, dynamic> _acChargeCurrentGet() {
    if (!_acChargeCurrentSupported) {
      return {
        'success': true,
        'supported': false,
        'available': true,
        'configState': 0,
        'state': null,
        'label': null,
      };
    }
    if (!_acChargeCurrentAvailable) {
      return {
        'success': false,
        'supported': _acChargeCurrentSupported,
        'available': false,
        'error': 'vehicle_data_unavailable',
      };
    }
    return {
      'success': true,
      'supported': true,
      'available': true,
      'configState': 1,
      'state': _acChargeCurrentState,
      'label': _acChargeLabels[_acChargeCurrentState],
    };
  }

  Map<String, dynamic> _handleAcChargeCurrentLimitPost(Map<String, dynamic> body) {
    final raw = body['state'];
    final state = raw is num ? raw.toInt() : int.tryParse('$raw');
    if (state == null || state < 1 || state > 5) {
      return {'success': false, 'error': 'state must be an integer from 1 to 5'};
    }
    if (!_acChargeCurrentSupported || !_acChargeCurrentAvailable) {
      return {
        'success': false,
        'supported': _acChargeCurrentSupported,
        'available': _acChargeCurrentAvailable,
        'error': 'vehicle_control.not_supported',
      };
    }
    _acChargeCurrentState = state;
    return {
      'success': true,
      'commandSuccess': true,
      'outcome': 'success',
      'path': 'sdk',
      'message': 'local_sent',
      'supported': true,
      'available': true,
      'state': state,
      'label': _acChargeLabels[state],
      'confirmation': 'local',
    };
  }

  Map<String, dynamic> _handleVehiclePower({required bool on}) {
    return {
      'success': true,
      'commandSuccess': true,
      'confirmation': 'local',
      'outcome': 'success',
      'message': on ? 'power on · confirmed by the car' : 'power off · confirmed by the car',
      'powerBefore': on ? 0 : 1,
      'powerAfter': on ? 1 : 0,
      'path': 'sdk',
    };
  }

  Map<String, dynamic> _handleChargeCapPost(Map<String, dynamic> body) {
    if (body['percent'] != null) _chargeCapPercent = (body['percent'] as num).toInt();
    if (body['enabled'] != null) _chargeCapEnabled = body['enabled'] == true;
    return _ok('charge-cap');
  }

  Map<String, dynamic> _handleLights(Map<String, dynamic> body) {
    final target = body['target'] as String? ?? '';
    final enable = body['enable'] == true;
    final lights = _map('lights');
    if (target == 'readingLight') {
      lights['readingLight'] = enable;
    }
    _state['lights'] = lights;
    return _ok('lights');
  }

  void _setOverallLock({required bool locked}) {
    final v = locked ? 1 : 2;
    _state['doors'] = {
      ..._map('doors'),
      'lf': v,
      'rf': v,
      'lr': v,
      'rr': v,
      'overall': v,
      'scope': 'vehicle',
      'source': 'mock',
    };
  }

  Map<String, dynamic> _map(String key) =>
      Map<String, dynamic>.from(_state[key] as Map<String, dynamic>? ?? {});

  Map<String, dynamic> _ok(
    String path, {
    String? message,
    String confirmation = 'local',
  }) =>
      {
        'success': true,
        'commandSuccess': true,
        'path': 'local',
        'latencyMs': 42,
        'outcome': 'success',
        'confirmation': confirmation,
        ...? (message == null ? null : {'message': message}),
      };
}
