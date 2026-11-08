import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n_x.dart';
import '../../core/layout/scroll_insets.dart';
import '../../core/widgets/requires_connection.dart';
import 'vehicle_hu_commands_panel.dart';

/// Advanced head-unit / cluster HTTP controls (confirmations required).
class VehicleHuRemoteScreen extends ConsumerStatefulWidget {
  const VehicleHuRemoteScreen({super.key});

  @override
  ConsumerState<VehicleHuRemoteScreen> createState() => _VehicleHuRemoteScreenState();
}

class _VehicleHuRemoteScreenState extends ConsumerState<VehicleHuRemoteScreen> {
  bool _busy = false;
  String? _feedback;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return RequiresConnection(
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.huRemoteTitle)),
        body: ListView(
          padding: scrollBottomPadding(context),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(l10n.huRemoteIntro, style: Theme.of(context).textTheme.bodyMedium),
            ),
            VehicleHuCommandsPanel(
              busy: _busy,
              onBusyChanged: (v) => setState(() => _busy = v),
              onFeedback: (m) => setState(() => _feedback = m),
              enabled: !_busy,
            ),
            if (_feedback != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_feedback!, textAlign: TextAlign.center),
              ),
          ],
        ),
      ),
    );
  }
}
