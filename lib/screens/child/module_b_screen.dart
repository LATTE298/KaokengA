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
                    (pack) => PressableChildCard(
                      // ไม่พูด kTtsMemoryStart ตรงนี้ — MemoryGameScreen.initState
                      // ประกาศเองอยู่แล้ว พูดสองที่ติดกันทำให้เสียงแรกโดนตัดเป็นกระตุก
                      onTap: () => context.push(kRouteMemoryGame),
                      child: Container(
                        width: 260,
                        height: 320,
                        decoration: BoxDecoration(
                          color: kBlueLight,
                          borderRadius: kRadiusLg,
                          boxShadow: const [kShadowMd],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.grid_view_rounded,
                              size: 96,
                              color: kBlueDark,
                            ),
                            const SizedBox(height: kSpace4),
                            Text(pack.titleTh, style: kTextXL),
                          ],
                        ),
                      ),
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
