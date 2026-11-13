import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/secure_settings_store.dart';
import '../../design/od_design.dart';
import '../../models/connection_draft.dart';
import '../../state/companion_app_controller.dart';
import '../widgets/od_widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.initialDraft});

  /// When editing connection from profile, pre-fill from saved values.
  final ConnectionDraft? initialDraft;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  CompanionConnectionMode _mode = CompanionConnectionMode.tunnel;
  late final TextEditingController _urlCtrl;
  late final TextEditingController _deviceCtrl;
  late final TextEditingController _codeCtrl;
  bool _hydrated = false;

  _LoginScreenState() {
    _urlCtrl = TextEditingController();
    _deviceCtrl = TextEditingController();
    _codeCtrl = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hydrated) return;
    _hydrated = true;
    final draft = widget.initialDraft ?? ref.read(companionAppControllerProvider).savedConnectionDraft;
    _mode = draft.mode;
    _urlCtrl.text = draft.address;
    _deviceCtrl.text = draft.deviceId;
    _codeCtrl.text = draft.accessCode;
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    _deviceCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  ConnectionDraft _draft() => ConnectionDraft(
        mode: _mode,
        address: _urlCtrl.text,
        deviceId: _deviceCtrl.text,
        accessCode: _codeCtrl.text,
      );

  @override
  Widget build(BuildContext context) {
    final ctrl = ref.watch(companionAppControllerProvider);
    final bottom = MediaQuery.paddingOf(context).bottom;
    final top = MediaQuery.paddingOf(context).top;
    final addressHint = _mode == CompanionConnectionMode.tunnel
        ? 'https://your-tunnel.trycloudflare.com'
        : 'http://192.168.0.12:8080';
    return ColoredBox(
      color: OdColors.bg,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 28 + top, 24, 24 + bottom),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('OVERDRIVE', style: odBrand(), textDirection: TextDirection.ltr),
                      const SizedBox(height: 4),
                      Text(
                        'התחברות לשרת ברכב',
                        style: odMuted(11).copyWith(color: const Color(0xFF53647C)),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'פרטי הגישה כפי שמוצגים באפליקציית OverDrive ברכב (login / מנהרה).',
                        style: odMuted(13).copyWith(height: 1.55),
                      ),
                      const SizedBox(height: 18),
                      Text('סוג חיבור', style: odMuted(12)),
                      const SizedBox(height: 8),
                      _ModePicker(
                        mode: _mode,
                        onChanged: (m) {
                          setState(() => _mode = m);
                          ref.read(companionAppControllerProvider).clearLoginFeedback();
                        },
                      ),
                      const SizedBox(height: 16),
                      _field(
                        _mode == CompanionConnectionMode.tunnel ? 'כתובת מנהרה' : 'כתובת מקומית (IP:פורט)',
                        _urlCtrl,
                        hint: addressHint,
                      ),
                      const SizedBox(height: 10),
                      _field(
                        'מזהה מכשיר (Device ID)',
                        _deviceCtrl,
                        hint: 'אופציונלי אם השרת מחזיר ב-/auth/status',
                      ),
                      const SizedBox(height: 10),
                      _field(
                        'קוד גישה (Access code)',
                        _codeCtrl,
                        hint: 'מינימום 8 תווים · נשלח כ-deviceId-accessCode',
                        obscure: true,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'האימות הוא POST /auth/token עם אסימון מלא {מזהה}-{קוד}. אין שם משתמש או סיסמה בשרת זה.',
                        style: odMuted(11).copyWith(height: 1.5),
                      ),
                      if (ctrl.connectionTestHebrew != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          ctrl.connectionTestHebrew!,
                          style: odBody(
                            13,
                            FontWeight.w600,
                            ctrl.connectionTestOk ? const Color(0xFF176044) : const Color(0xFF9B1C1C),
                          ),
                        ),
                      ],
                      if (ctrl.loginErrorHebrew != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          ctrl.loginErrorHebrew!,
                          style: odBody(13, FontWeight.w600, const Color(0xFF9B1C1C)),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              OdSecondaryButton(
                label: ctrl.testingConnection ? 'בודק חיבור…' : 'בדיקת חיבור',
                onPressed: ctrl.testingConnection
                    ? null
                    : () => ref.read(companionAppControllerProvider).testConnection(_draft()),
              ),
              const SizedBox(height: 10),
              OdPrimaryButton(
                label: ctrl.connecting ? 'מתחבר…' : 'התחברות',
                onPressed: ctrl.connecting
                    ? null
                    : () => ref.read(companionAppControllerProvider).connect(_draft()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c, {String? hint, bool obscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: odMuted(12)),
        const SizedBox(height: 6),
        TextField(
          controller: c,
          onChanged: (_) => ref.read(companionAppControllerProvider).clearLoginFeedback(),
          obscureText: obscure,
          style: odBody(15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: odMuted(13),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: OdColors.line),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: OdColors.line),
            ),
          ),
        ),
      ],
    );
  }
}

class _ModePicker extends StatelessWidget {
  const _ModePicker({required this.mode, required this.onChanged});

  final CompanionConnectionMode mode;
  final ValueChanged<CompanionConnectionMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ModeChip(
            label: 'מנהרה מרוחקת',
            selected: mode == CompanionConnectionMode.tunnel,
            onTap: () => onChanged(CompanionConnectionMode.tunnel),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ModeChip(
            label: 'רשת מקומית',
            selected: mode == CompanionConnectionMode.local,
            onTap: () => onChanged(CompanionConnectionMode.local),
          ),
        ),
      ],
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? OdColors.navActiveBg : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: selected ? OdColors.blue : OdColors.line),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: odBody(13, selected ? FontWeight.w700 : FontWeight.w500, selected ? OdColors.blue : OdColors.ink),
          ),
        ),
      ),
    );
  }
}
