import 'package:flutter/material.dart';

enum ExternalDismissibleEffect { normal, resize }

class ExternalDismissible extends StatefulWidget {
  final Widget child;
  final VoidCallback onDismissed;
  final bool dismiss;
  final ExternalDismissibleEffect effect;

  const ExternalDismissible({
    super.key,
    required this.child,
    required this.dismiss,
    required this.onDismissed,
    this.effect = ExternalDismissibleEffect.normal,
  });

  @override
  State<ExternalDismissible> createState() => _ExternalDismissibleState();
}

class _ExternalDismissibleState extends State<ExternalDismissible>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late final AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _resizeAnimation;

  bool _isDismissing = false;

  bool get isNormal => widget.effect == ExternalDismissibleEffect.normal;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: isNormal ? 300 : 160),
    );
    _initAnimations();
  }

  void _initAnimations() {
    if (isNormal) {
      _slideAnimation =
          Tween<Offset>(
            begin: Offset.zero,
            end: const Offset(1.0, 0.0),
          ).animate(
            CurvedAnimation(
              parent: _controller,
              curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
            ),
          );
      _resizeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
        ),
      );
    } else {
      _slideAnimation = const AlwaysStoppedAnimation(Offset.zero);
      _resizeAnimation = Tween<double>(
        begin: 1.0,
        end: 0.0,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    }
  }

  @override
  bool get wantKeepAlive => _isDismissing;

  @override
  void didUpdateWidget(covariant ExternalDismissible oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.dismiss && widget.dismiss) {
      _dismiss();
    }
  }

  Future<void> _dismiss() async {
    if (_isDismissing) return;
    if (!mounted) return;
    _isDismissing = true;
    updateKeepAlive();

    await _controller.forward();

    if (mounted) {
      widget.onDismissed();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    Widget content = widget.child;

    if (isNormal) {
      content = SlideTransition(position: _slideAnimation, child: content);
    }

    return SizeTransition(
      axisAlignment: 0.5,
      sizeFactor: _resizeAnimation,
      axis: Axis.vertical,
      child: content,
    );
  }
}
