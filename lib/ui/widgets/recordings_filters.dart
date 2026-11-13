import 'package:flutter/material.dart';

import '../../demo/demo_models.dart';
import '../../design/od_design.dart';

/// HTML `.filter-tab.active::before` — chevron glyph before label (‹), not a checkmark.
class OdFilterActiveChevron extends StatelessWidget {
  const OdFilterActiveChevron({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 6),
      child: Text(
        '‹',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color, height: 1),
      ),
    );
  }
}

class OdRecordingTypeTab extends StatelessWidget {
  const OdRecordingTypeTab({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const fg = Color(0xFF174B9A);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: Container(
          constraints: const BoxConstraints(minHeight: 36),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFE3ECFB) : Colors.transparent,
            borderRadius: BorderRadius.circular(99),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (active) const OdFilterActiveChevron(color: fg),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: active ? fg : OdColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OdRecordingFilterChip extends StatelessWidget {
  const OdRecordingFilterChip({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
    this.severityTone,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;
  final String? severityTone;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (severityTone) {
      'alert' when active => (const Color(0xFFFFF4E6), const Color(0xFFB36A00)),
      'critical' when active => (const Color(0xFFFDECEC), const Color(0xFFC0392B)),
      _ when active => (const Color(0xFFE3ECFB), const Color(0xFF174B9A)),
      _ => (const Color(0xFFEEF1F6), OdColors.muted),
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: Container(
          constraints: const BoxConstraints(minHeight: 36),
          margin: const EdgeInsetsDirectional.only(start: 8, bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(99),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (active) OdFilterActiveChevron(color: fg),
              Text(
                label,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OdClipTypeBadge extends StatelessWidget {
  const OdClipTypeBadge({super.key, required this.type, required this.label});

  final RecordingType type;
  final String label;

  Color? get _dot => switch (type) {
        RecordingType.sentry => const Color(0xFFFF8A7A),
        RecordingType.proximity => const Color(0xFF85CFFF),
        RecordingType.normal => const Color(0xFF5DDBB6),
        RecordingType.replay => null,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9),
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0x9E000000),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_dot != null) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: _dot, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
