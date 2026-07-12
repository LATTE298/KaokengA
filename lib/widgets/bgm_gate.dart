import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/bgm_provider.dart';

/// ครอบทั้งแอปเพื่อเริ่มเพลงธีม: Android เริ่ม+fade-in ทันทีตอนเปิดแอป;
/// เว็บมัก block จนกว่าจะแตะครั้งแรก → Listener เรียก start() ซ้ำ (idempotent)
class BgmGate extends ConsumerStatefulWidget {
  const BgmGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<BgmGate> createState() => _BgmGateState();
}

class _BgmGateState extends ConsumerState<BgmGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(bgmServiceProvider).start();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => ref.read(bgmServiceProvider).start(),
      child: widget.child,
    );
  }
}
