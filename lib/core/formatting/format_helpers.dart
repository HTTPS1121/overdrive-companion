import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/l10n_x.dart';

/// ISO-8601 vehicle timestamps → local, human-readable.
String formatVehicleTimestamp(BuildContext context, String? iso) {
  if (iso == null || iso.trim().isEmpty) return '—';
  final parsed = DateTime.tryParse(iso);
  if (parsed == null) return iso;
  final local = parsed.toLocal();
  final locale = Localizations.localeOf(context);
  final pattern = locale.languageCode == 'he' ? 'd בMMM yyyy, HH:mm' : 'MMM d, yyyy, h:mm a';
  try {
    return DateFormat(pattern, locale.languageCode).format(local);
  } catch (_) {
    return DateFormat.yMMMd(locale.languageCode).add_Hm().format(local);
  }
}

String formatByteCount(BuildContext context, int? bytes) {
  if (bytes == null) return '';
  final l10n = context.l10n;
  if (bytes < 1024) return l10n.formatBytesBytes(bytes);
  if (bytes < 1024 * 1024) {
    final kb = bytes / 1024;
    final kbLabel = kb >= 10 ? kb.round().toString() : kb.toStringAsFixed(1);
    return l10n.formatBytesKib(kbLabel);
  }
  final mb = bytes / (1024 * 1024);
  return l10n.formatBytesMib(mb.toStringAsFixed(mb >= 10 ? 0 : 1));
}
