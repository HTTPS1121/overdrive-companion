import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive_companion/core/format/freshness.dart';
import 'package:overdrive_companion/l10n/app_localizations.dart';

void main() {
  test('fetchedAgoLabelLocalized uses now for fresh poll', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    final f = DataFreshness(
      serverEpochSec: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      fetchedAt: DateTime.now(),
    );
    expect(f.fetchedAgoLabelLocalized(l10n, DateTime.now()), contains('now'));
  });

  test('ageLabelLocalized avoids zero seconds wording', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    final now = DateTime.now();
    final f = DataFreshness(
      serverEpochSec: now.millisecondsSinceEpoch ~/ 1000,
      fetchedAt: now.add(const Duration(seconds: 2)),
    );
    expect(f.ageLabelLocalized(l10n).toLowerCase(), contains('now'));
  });
}
