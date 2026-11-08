import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive_companion/core/format/freshness.dart';

void main() {
  test('fetchedAgoLabelHe uses עכשיו for fresh poll', () {
    final f = DataFreshness(
      serverEpochSec: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      fetchedAt: DateTime.now(),
    );
    expect(f.fetchedAgoLabelHe(DateTime.now()), 'עודכן עכשיו');
  });

  test('ageLabelHe avoids zero seconds wording', () {
    final now = DateTime.now();
    final f = DataFreshness(
      serverEpochSec: now.millisecondsSinceEpoch ~/ 1000,
      fetchedAt: now.add(const Duration(seconds: 2)),
    );
    expect(f.ageLabelHe(), 'עכשיו');
  });
}
