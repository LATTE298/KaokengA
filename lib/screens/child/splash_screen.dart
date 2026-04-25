import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/tts_strings_th.dart';
import '../../providers/tts_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

// Splash screen per spec 02 §SplashScreen + spec 03 Flow 1 steps 1-2.
// 800ms logo animate-in, greeting TTS, navigate to ModeSelect at 1500ms.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _logoController;
  late final Animation<double> _logoScale;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );
    _logoController.forward();

    // Fire TTS greeting as soon as frame is mounted.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ttsServiceProvider).speak(kTtsSplashGreeting);
    });

    _navTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) context.go(kRouteModeSelect);
    });
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kYellowLight, kWarmWhite],
          ),
        ),
        child: Center(
          child: ScaleTransition(
            scale: _logoScale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Placeholder logo — replace with actual brand mark asset.
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: kYellowPrimary,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Icon(
                    Icons.wb_sunny_rounded,
                    size: 96,
                    color: kTextPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                Text('ชีวิตประจำวัน', style: kTextXL),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
