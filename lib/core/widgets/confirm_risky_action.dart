import 'package:flutter/material.dart';

typedef RiskyAction = Future<void> Function();

Future<bool> confirmRiskyAction(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ביטול')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(confirmLabel)),
      ],
    ),
  );
  return ok == true;
}
