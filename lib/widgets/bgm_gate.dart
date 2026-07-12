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

class _BgmGateState extends ConsumerState<BgmGate> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(bgmServiceProvider).start();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // พับจอ/สลับแอป → พักเพลง; กลับมา → เล่นต่อ (ถ้าเปิดอยู่). แก้บั๊กเพลงเล่นตลอด
  // แม้พับแอปลงไปแล้ว (พบบน Android 2026-07-13)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final bgm = ref.read(bgmServiceProvider);
    if (state == AppLifecycleState.resumed) {
      bgm.resumeForeground();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      bgm.pauseForBackground();
    }
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
