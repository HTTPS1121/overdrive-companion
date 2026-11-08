import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive_companion/features/integrations/automation_state_readout.dart';
import 'package:overdrive_companion/l10n/app_localizations.dart';
import 'package:overdrive_companion/l10n/app_localizations_en.dart';
import 'package:overdrive_companion/l10n/app_localizations_he.dart';

void main() {
  test('automationEngineStateRows maps engine then activeCount with distinct labels', () {
    final l10nEn = AppLocalizationsEn('en');
    final l10nHe = AppLocalizationsHe('he');

    final state = {'engine': 'idle', 'activeCount': 2};

    final enRows = automationEngineStateRows(state, l10nEn);
    expect(enRows.length, 2);
    expect(enRows[0].key, 'Engine state');
    expect(enRows[0].value, 'idle');
    expect(enRows[1].key, 'Active automations');
    expect(enRows[1].value, '2');

    final heRows = automationEngineStateRows(state, l10nHe);
    expect(heRows.length, 2);
    expect(heRows[0].key, 'מצב מנוע');
    expect(heRows[1].key, 'אוטומציות פעילות');
  });
}
