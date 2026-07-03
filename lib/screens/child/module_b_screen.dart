import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/content_providers.dart';
import '../../routes/app_routes.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/typography.dart';
import '../../widgets/child_back_button.dart';
import '../../widgets/child/child_async_view.dart';
import '../../widgets/child/pressable_child_card.dart';

// Module B hub (spec 02 §ModuleBScreen). MVP has a single pack.
class ModuleBScreen extends ConsumerWidget {
  const ModuleBScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPack = ref.watch(memoryPackProvider);

    return Scaffold(
      backgroundColor: kWarmWhite,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: ChildAsyncView(
                value: asyncPack,
                loading: const CircularProgressIndicator(),
                error: (_, __) => Text('โหลดเกมไม่สำเร็จ', style: kTextLg),
                data:
                    (pack) => LayoutBuilder(
                      builder: (context, constraints) {
                        // ขนาดการ์ดคิดเป็นสัดส่วนจากพื้นที่จริง (กฎ responsive —
                        // CLAUDE.md ข้อ 3) เดิม fix 260x320 พอดีแท็บเล็ตแต่เบียดจอเตี้ย
                        // (เช่น S8+ สูง ~360 หัก SafeArea เหลือไม่พอ)
                        final cardHeight = (constraints.maxHeight * 0.85)
                            .clamp(200.0, 320.0)
                            .toDouble();
                        final cardWidth = cardHeight * (260 / 320);
                        return PressableChildCard(
                          // ไม่พูด kTtsMemoryStart ตรงนี้ — MemoryGameScreen.initState
                          // ประกาศเองอยู่แล้ว พูดสองที่ติดกันทำให้เสียงแรกโดนตัดเป็นกระตุก
                          onTap: () => context.push(kRouteMemoryGame),
                          child: Container(
                            width: cardWidth,
                            height: cardHeight,
                            decoration: BoxDecoration(
                              color: kBlueLight,
                              borderRadius: kRadiusLg,
                              boxShadow: const [kShadowMd],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.grid_view_rounded,
                                  size: cardHeight * 0.3,
                                  color: kBlueDark,
                                ),
                                const SizedBox(height: kSpace4),
                                Text(pack.titleTh, style: kTextXL),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
              ),
            ),
            const Positioned(top: 8, left: 8, child: ChildBackButton()),
          ],
        ),
      ),
    );
  }
}
