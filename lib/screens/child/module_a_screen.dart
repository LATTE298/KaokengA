import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/tts_strings_th.dart';
import '../../providers/parent_dashboard_providers.dart';
import '../../providers/tts_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/typography.dart';
import '../../widgets/child_back_button.dart';
import '../../widgets/child/child_async_view.dart';
import '../../widgets/child/scenario_card.dart';

// Module A scenario list hub (spec 02 §ModuleAScreen, spec 03 Flow 1 §5).
class ModuleAScreen extends ConsumerWidget {
  const ModuleAScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncList = ref.watch(enabledScenariosProvider);

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
              child: ChildAsyncView(
                value: asyncList,
                error:
                    (_, __) =>
                        Center(child: Text(kLabelModuleA, style: kTextXL)),
                isEmpty: (scenarios) => scenarios.isEmpty,
                empty: Center(child: Text('ยังไม่มีสถานการณ์', style: kTextLg)),
                data: (scenarios) {
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: scenarios.length,
                    separatorBuilder: (_, __) => const SizedBox(width: kSpace4),
                    itemBuilder: (context, i) {
                      final s = scenarios[i];
                      return ScenarioCard(
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
