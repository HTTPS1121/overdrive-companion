import '../../l10n/app_localizations.dart';

/// Engine card rows from GET `/api/automations/state` (fixed label mapping).
List<MapEntry<String, String>> automationEngineStateRows(
  Map<String, dynamic> state,
  AppLocalizations l10n,
) {
  final rows = <MapEntry<String, String>>[];
  if (state['engine'] != null) {
    rows.add(MapEntry(l10n.automationLabelEngineState, state['engine']?.toString() ?? '—'));
  }
  if (state['activeCount'] != null) {
    rows.add(MapEntry(l10n.automationLabelActiveAutomations, state['activeCount']?.toString() ?? '—'));
  }
  return rows;
}
