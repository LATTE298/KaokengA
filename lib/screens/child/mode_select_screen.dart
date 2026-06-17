import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/tts_strings_th.dart';
import '../../providers/tts_provider.dart';
import '../../routes/app_routes.dart';
import '../../services/haptic_service.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/typography.dart';
import '../../widgets/child/module_card.dart';

class ModeSelectScreen extends ConsumerWidget {
  const ModeSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: kWarmWhite,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: kSpace4,
              right: kSpace4,
              child: _LogoSmall(
                onLongPressComplete: () {
                  HapticService.parentGateComplete();
                  context.push(kRouteParentGate);
                },
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: kSpace8,
                  vertical: kSpace4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ModuleCard(
                      label: kLabelModuleA,
                      description: 'ลองทำกิจกรรม',
                      icon: Icons.home_rounded,
                      background: kYellowLight,
                      onTap: () {
                        ref.read(ttsServiceProvider).speak(kTtsModuleADesc);
                        context.push(kRouteModuleA);
                      },
                    ),
                    const SizedBox(width: kSpace4),
                    ModuleCard(
                      label: kLabelModuleB,
                      description: 'จับคู่รูปภาพ',
                      icon: Icons.grid_view_rounded,
                      background: kBlueLight,
                      onTap: () {
                        ref.read(ttsServiceProvider).speak(kTtsModuleBDesc);
                        context.push(kRouteModuleB);
                      },
                    ),
                    const SizedBox(width: kSpace4),
                    ModuleCard(
                      label: kLabelModuleC,
                      description: 'เรียนคำศัพท์',
                      icon: Icons.record_voice_over_rounded,
                      background: kYellowAccent,
                      onTap: () {
                        ref.read(ttsServiceProvider).speak(kTtsModuleCDesc);
                        context.push(kRouteModuleC);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// Logo with 3s long-press gate to parent mode (spec 03 Flow 4 step 1).
// Miniaturized to act as a hidden corner button.
class _LogoSmall extends StatefulWidget {
  const _LogoSmall({required this.onLongPressComplete});
  final VoidCallback onLongPressComplete;

  @override
  State<_LogoSmall> createState() => _LogoSmallState();
}

class _LogoSmallState extends State<_LogoSmall> with SingleTickerProviderStateMixin {
  late final AnimationController _ringController;

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _ringController.dispose();
    super.dispose();
  }

  void _onPressStart() {
    _ringController.forward(from: 0).then((status) {
      if (_ringController.isCompleted) {
        widget.onLongPressComplete();
      }
    });
  }

  void _onPressEnd() {
    if (!_ringController.isCompleted) {
      _ringController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _onPressStart(),
      onTapUp: (_) => _onPressEnd(),
      onTapCancel: _onPressEnd,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _ringController,
            builder: (context, _) {
              return SizedBox(
                width: 58,
                height: 58,
                child: CircularProgressIndicator(
                  value: _ringController.value,
                  strokeWidth: 3,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(kBluePrimary),
                ),
              );
            },
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: kYellowPrimary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.wb_sunny_rounded,
              size: 28,
              color: kTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}