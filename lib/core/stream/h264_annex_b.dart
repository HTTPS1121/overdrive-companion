import 'dart:typed_data';

/// Helpers aligned with upstream bare Annex-B WebSocket messages.
class H264AnnexB {
  static bool isKeyframe(Uint8List data) => _anyNalType(data, 5);

  static bool isConfig(Uint8List data) => _anyNalType(data, 7) || _anyNalType(data, 8);

  static bool _anyNalType(Uint8List data, int type) {
    var i = 0;
    while (i + 4 < data.length) {
      if (_nalType(data, i) == type) return true;
      final next = _nextStart(data, i + 1);
      if (next < 0) break;
      i = next;
    }
    return false;
  }

  static int _nalType(Uint8List data, int start) {
    var i = start;
    if (i + 3 < data.length && data[i] == 0 && data[i + 1] == 0) {
      if (data[i + 2] == 1) {
        i += 3;
      } else if (i + 3 < data.length && data[i + 2] == 0 && data[i + 3] == 1) {
        i += 4;
      }
    }
    if (i >= data.length) return -1;
    return data[i] & 0x1F;
  }

  static int _nextStart(Uint8List data, int from) {
    for (var i = from; i < data.length - 3; i++) {
      if (data[i] == 0 && data[i + 1] == 0 &&
          (data[i + 2] == 1 || (i + 3 < data.length && data[i + 2] == 0 && data[i + 3] == 1))) {
        return i;
      }
    }
    return -1;
  }
}
