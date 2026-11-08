import 'package:flutter/material.dart';

import '../../data/models/vehicle_state.dart';
import '../theme/app_text.dart';
import '../theme/app_theme.dart';

class BatteryHero extends StatelessWidget {
  const BatteryHero({
    super.key,
    required this.battery,
    required this.locked,
    required this.drivingLabel,
  });

  final BatteryInfo? battery;
  final bool? locked;
  final String? drivingLabel;

  @override
  Widget build(BuildContext context) {
    final colors = OverdriveColors.of(context);
    final soc = battery?.soc;
    final range = battery?.displayRangeKm;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'BYD Atto 3',
              style: numericTextStyle(
                Theme.of(context).textTheme.labelLarge,
              ).copyWith(color: colors.muted, letterSpacing: 0.4),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: 104,
                  height: 104,
                  child: CustomPaint(
                    painter: _RingPainter(
                      progress: (soc ?? 0) / 100,
                      color: _socColor(soc, colors),
                      track: const Color(0xFF243044),
                    ),
                    child: Center(
                      child: Text(
                        soc != null ? '${soc.round()}%' : '—',
                        style: numericTextStyle(
                          Theme.of(context).textTheme.headlineMedium,
                          weight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'טווח משוער',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        range != null ? '$range km' : '—',
                        style: numericTextStyle(
                          Theme.of(context).textTheme.headlineSmall,
                          weight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _Chip(
                            icon: locked == true
                                ? Icons.lock
                                : locked == false
                                    ? Icons.lock_open
                                    : Icons.help_outline,
                            label: locked == true
                                ? 'נעול'
                                : locked == false
                                    ? 'פתוח'
                                    : 'נעילה לא ידועה',
                          ),
                          if (drivingLabel != null)
                            _Chip(icon: Icons.speed, label: drivingLabel!),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _socColor(double? soc, OverdriveColors colors) {
    if (soc == null) return colors.muted;
    if (soc < 15) return colors.danger;
    if (soc < 30) return colors.warn;
    return colors.accent;
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2533),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A3545)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.color,
    required this.track,
  });

  final double progress;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 9.0;
    final rect = Offset.zero & size;
    final start = -3.14 / 2;
    final sweep = 3.14 * 2 * progress.clamp(0, 1);

    final bg = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final fg = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect.deflate(stroke), 0, 3.14 * 2, false, bg);
    canvas.drawArc(rect.deflate(stroke), start, sweep, false, fg);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
