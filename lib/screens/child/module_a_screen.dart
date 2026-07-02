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
              // ลด padding แนวตั้งเมื่อเทียบกับเดิม (top kSpace12) เพราะจอเตี้ยต้องการพื้นที่
              // ทุก px — ยกหัวขึ้นด้วย kSpace8 พอให้ไม่ชนปุ่มย้อนกลับ
              padding: const EdgeInsets.only(
                top: kSpace4,
                left: kSpace8,
                right: kSpace8,
                bottom: kSpace4,
              ),
              child: ChildAsyncView(
                value: asyncList,
                error:
                    (_, __) =>
                        Center(child: Text(kLabelModuleA, style: kTextXL)),
                isEmpty: (scenarios) => scenarios.isEmpty,
                empty: Center(child: Text('ยังไม่มีสถานการณ์', style: kTextLg)),
                data: (scenarios) {
                  // วัดพื้นที่จริงที่มี แล้วคำนวณความสูงการ์ดจากตรงนั้น (spec 1.3) —
                  // การ์ดทุกใบจะปรับขนาดตามเครื่องอัตโนมัติ ไม่ล้นไม่ว่าจอขนาดไหน
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      // เผื่อพื้นที่ปุ่มย้อนกลับด้านบนซ้ายเล็กน้อย แล้วใช้ความสูงที่เหลือ
                      // ทั้งหมดเป็นความสูงการ์ด (clamp กันเตี้ย/สูงเกินในเคสสุดขั้ว)
                      final availableHeight = constraints.maxHeight - kSpace8;
                      final cardHeight =
                          availableHeight.clamp(200.0, 420.0);

                      return Align(
                        alignment: Alignment.centerLeft,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemCount: scenarios.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: kInteractiveGapMin),
                          itemBuilder: (context, i) {
                            final s = scenarios[i];
                            return Center(
                              child: ScenarioCard(
                                summary: s,
                                cardHeight: cardHeight,
                                onTap: () {
                                  ref
                                      .read(ttsServiceProvider)
                                      .speak(s.titleTh);
                                  context.push(
                                    '$kRouteScenarioGame/${s.scenarioId}',
                                  );
                                },
                              ),
                            );
                          },
                        ),
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