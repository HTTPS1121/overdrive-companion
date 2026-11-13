import 'package:flutter/material.dart';

/// Horizontal row scrolled to the visual start in RTL (right edge) on first layout.
class OdRtlScrollRow extends StatefulWidget {
  const OdRtlScrollRow({
    super.key,
    required this.padding,
    required this.child,
    this.clipBehavior = Clip.hardEdge,
  });

  final EdgeInsetsGeometry padding;
  final Widget child;
  final Clip clipBehavior;

  @override
  State<OdRtlScrollRow> createState() => _OdRtlScrollRowState();
}

class _OdRtlScrollRowState extends State<OdRtlScrollRow> {
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToRtlStart());
  }

  void _jumpToRtlStart() {
    if (!_controller.hasClients) return;
    final pos = _controller.position;
    _controller.jumpTo(pos.minScrollExtent);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final band = constraints.maxWidth.isFinite ? constraints.maxWidth : 0.0;
        return SingleChildScrollView(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          padding: widget.padding,
          clipBehavior: widget.clipBehavior,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: band),
            child: widget.child,
          ),
        );
      },
    );
  }
}
