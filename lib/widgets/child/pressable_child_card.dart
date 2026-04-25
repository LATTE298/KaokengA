import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PressableChildCard extends StatefulWidget {
  const PressableChildCard({
    super.key,
    required this.child,
    required this.onTap,
    this.scale = 1.04,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeInOut,
    this.playClickSound = false,
  });

  final Widget child;
  final VoidCallback onTap;
  final double scale;
  final Duration duration;
  final Curve curve;
  final bool playClickSound;

  @override
  State<PressableChildCard> createState() => _PressableChildCardState();
}

class _PressableChildCardState extends State<PressableChildCard> {
  bool _pressed = false;

  void _setPressed(bool pressed) {
    if (_pressed == pressed) return;
    setState(() => _pressed = pressed);
  }

  void _onTapUp(TapUpDetails _) {
    _setPressed(false);
    if (widget.playClickSound) {
      SystemSound.play(SystemSoundType.click);
    }
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapUp: _onTapUp,
      onTapCancel: () => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1.0,
        duration: widget.duration,
        curve: widget.curve,
        child: widget.child,
      ),
    );
  }
}
