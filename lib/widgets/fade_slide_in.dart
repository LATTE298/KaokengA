import 'package:flutter/material.dart';

// เอฟเฟกต์เข้าฉากเบาๆ ครั้งเดียวตอน mount: จางเข้า (fade) + เลื่อนขึ้นเล็กน้อย
// ตั้งใจให้ subtle (ระยะสั้น, curve นุ่ม) — เด็กกลุ่มดาวน์ซินโดรมไวต่อการกระตุ้น
// ทางสายตา จึงเลี่ยง bounce/สปริงแรงๆ. รองรับ delay เพื่อทำ stagger (ทยอยเข้าทีละใบ)
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 350),
    this.offset = 16,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final double offset; // ระยะเลื่อนขึ้นเริ่มต้น (px)

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _anim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future<void>.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: AnimatedBuilder(
        animation: _anim,
        builder:
            (context, child) => Transform.translate(
              offset: Offset(0, widget.offset * (1 - _anim.value)),
              child: child,
            ),
        child: widget.child,
      ),
    );
  }
}
