import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/tts_strings_th.dart';
import '../../models/scenario_config.dart';
import '../../providers/content_providers.dart';
import '../../providers/tts_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/typography.dart';
import '../../widgets/child_back_button.dart';

// Module A scenario list hub (spec 02 §ModuleAScreen, spec 03 Flow 1 §5).
class ModuleAScreen extends ConsumerWidget {
  const ModuleAScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncList = ref.watch(scenarioListProvider);

    return Scaffold(
      backgroundColor: kWarmWhite,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: kSpace12,
                left: kSpace8,
                right: kSpace8,
                bottom: kSpace6,
              ),
              child: asyncList.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (_, __) =>
                        Center(child: Text(kLabelModuleA, style: kTextXL)),
                data: (scenarios) {
                  if (scenarios.isEmpty) {
                    return Center(
                      child: Text('ยังไม่มีสถานการณ์', style: kTextLg),
                    );
                  }
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: scenarios.length,
                    separatorBuilder: (_, __) => const SizedBox(width: kSpace4),
                    itemBuilder: (context, i) {
                      final s = scenarios[i];
                      return _ScenarioCard(
                        summary: s,
                        onTap: () {
                          ref.read(ttsServiceProvider).speak(s.titleTh);
                          context.push('$kRouteScenarioGame/${s.scenarioId}');
                        },
                      );
                    },
                  );
                },
              ),
            ),
            const Positioned(top: 8, left: 8, child: ChildBackButton()),
          ],
        ),
      ),
    );
  }
}

// Spec 10 §ScenarioCard.
class _ScenarioCard extends StatefulWidget {
  const _ScenarioCard({required this.summary, required this.onTap});

  final ScenarioSummary summary;
  final VoidCallback onTap;

  @override
  State<_ScenarioCard> createState() => _ScenarioCardState();
}

class _ScenarioCardState extends State<_ScenarioCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 1.04 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: Container(
          width: 220,
          height: 280,
          decoration: BoxDecoration(
            color: kWarmSurface,
            borderRadius: kRadiusMd,
            border: Border.all(color: kWarmBorder, width: 1.5),
            boxShadow: const [kShadowSm],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  color: kYellowLight,
                  child: const Center(
                    child: Icon(
                      Icons.image_rounded,
                      size: 72,
                      color: kYellowDark,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(kSpace4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.summary.titleTh,
                        style: kChildLabel,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: kSpace2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: kSpace3,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: kBlueLight,
                          borderRadius: kRadiusFull,
                        ),
                        child: Text(
                          widget.summary.category,
                          style: kTextXs.copyWith(color: kBlueDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
