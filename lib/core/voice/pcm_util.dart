import 'dart:math';
import 'dart:typed_data';

/// Downsample float [-1,1] to PCM s16le at [outputRate] (simple averaging).
Uint8List floatToPcm16(List<double> input, {required int inputRate, required int outputRate}) {
  if (outputRate > inputRate) outputRate = inputRate;
  final ratio = inputRate / outputRate;
  final samples = <int>[];
  var remaining = ratio;
  var sum = 0.0;
  var weight = 0.0;
  for (final v in input) {
    var available = 1.0;
    while (available > 0) {
      final take = min(available, remaining);
      sum += v * take;
      weight += take;
      remaining -= take;
      available -= take;
      if (remaining <= 0.000001) {
        final sample = weight == 0 ? 0.0 : sum / weight;
        final clamped = sample.clamp(-1.0, 1.0);
        samples.add((clamped < 0 ? clamped * 32768 : clamped * 32767).round());
        remaining = ratio;
        sum = 0;
        weight = 0;
      }
    }
  }
  final out = ByteData(samples.length * 2);
  for (var i = 0; i < samples.length; i++) {
    out.setInt16(i * 2, samples[i], Endian.little);
  }
  return out.buffer.asUint8List();
}

/// Generate a valid silent PCM s16le mono frame (even byte length).
Uint8List silentPcmFrame({int samples = 320}) {
  assert(samples > 0);
  return Uint8List(samples * 2);
}
