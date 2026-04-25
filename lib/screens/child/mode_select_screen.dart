import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/tts_strings_th.dart';
import '../../providers/tts_provider.dart';
import '../../routes/app_routes.dart';
import '../../services/haptic_service.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/typography.dart';

// Child home screen (spec 02 §ModeSelectScreen).
// Three module cards + hidden logo long-press gate to parent side.
class ModeSelectScreen extends ConsumerWidget {
  const ModeSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: kWarmWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(kSpace6),
          child: Column(
            children: [
              _Logo(
                onLongPressComplete: () {
                  HapticService.parentGateComplete();
                  context.push(kRouteParentGate);
                },
              ),
              const SizedBox(height: kSpace10),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ModuleCard(
                          label: kLabelModuleA,
                          description: 'ลองทำกิจกรรม',
                          icon: Icons.home_rounded,
                          background: kYellowLight,
                          onTap: () {
                            ref.read(ttsServiceProvider).speak(kTtsModuleADesc);
                            context.push(kRouteModuleA);
                          },
                        ),
                        _ModuleCard(
                          label: kLabelModuleB,
                          description: 'จับคู่รูปภาพ',
                          icon: Icons.grid_view_rounded,
                          background: kBlueLight,
                          onTap: () {
                            ref.read(ttsServiceProvider).speak(kTtsModuleBDesc);
                            context.push(kRouteModuleB);
                          },
                        ),
                        _ModuleCard(
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
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Logo with 3s long-press gate to parent mode (spec 03 Flow 4 step 1).
class _Logo extends StatefulWidget {
  const _Logo({required this.onLongPressComplete});
  final VoidCallback onLongPressComplete;

  @override
  State<_Logo> createState() => _LogoState();
}

class _LogoState extends State<_Logo> with SingleTickerProviderStateMixin {
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
                width: 96,
                height: 96,
                child: CircularProgressIndicator(
                  value: _ringController.value,
                  strokeWidth: 4,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(kBluePrimary),
                ),
              );
            },
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: kYellowPrimary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.wb_sunny_rounded,
              size: 48,
              color: kTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// Module card per spec 10 §ModuleCard.
class _ModuleCard extends StatefulWidget {
  const _ModuleCard({
    required this.label,
    required this.description,
    required this.icon,
    required this.background,
    required this.onTap,
  });

  final String label;
  final String description;
  final IconData icon;
  final Color background;
  final VoidCallback onTap;

  @override
  State<_ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<_ModuleCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cardSize = (width / 3 - kSpace8).clamp(120.0, 240.0);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        SystemSound.play(SystemSoundType.click);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 1.04 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: Container(
          width: cardSize,
          height: cardSize * 1.2,
          padding: const EdgeInsets.all(kSpace4),
          decoration: BoxDecoration(
            color: widget.background,
            borderRadius: kRadiusLg,
            boxShadow: const [kShadowMd],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 80, color: kTextPrimary),
              const SizedBox(height: kSpace4),
              Text(widget.label, style: kTextLg, textAlign: TextAlign.center),
              const SizedBox(height: kSpace2),
              Text(
                widget.description,
                style: kTextSm,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
