import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> integrationSnack(BuildContext context, String text) {
  return Future.microtask(() {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  });
}

mixin FamilyLoaderMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  bool busy = false;

  Future<void> guard(Future<void> Function() fn) async {
    setState(() => busy = true);
    try {
      await fn();
    } catch (e) {
      if (mounted) await integrationSnack(context, e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
}
