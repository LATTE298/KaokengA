import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/content_providers.dart';
import '../../routes/app_routes.dart';
import '../../theme/colors.dart';
import '../../widgets/child/paper_background.dart';
import '../../theme/spacing.dart';
import '../../theme/typography.dart';
import '../../widgets/child_back_button.dart';
import '../../widgets/child/category_select_grid.dart';
import '../../widgets/child/child_async_view.dart';

// Module B hub — เลือกหมวดเกมจับคู่ภาพ (6 หมวดจากคลังคำศัพท์จริง) การ์ดโชว์
// รูปตัวอย่างของหมวด + ชื่อหมวด แตะแล้วเข้าเกมของหมวดนั้น
class ModuleBScreen extends ConsumerWidget {
  const ModuleBScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPacks = ref.watch(memoryPacksProvider);

    return Scaffold(
      backgroundColor: kWarmWhite,
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(child: PaperBackground()),
            Padding(
              // ซ้ายพ้นปุ่มย้อนกลับที่ลอยมุมบนซ้าย (8 + 64 = 72) แบบเดียวกับ sound board
              padding: const EdgeInsets.fromLTRB(
                kTouchTargetMin + kSpace4,
                kSpace6,
                kSpace6,
                kSpace5,
              ),
              child: ChildAsyncView(
                value: asyncPacks,
                loading: const Center(child: CircularProgressIndicator()),
                error: (_, __) => Text('โหลดเกมไม่สำเร็จ', style: kTextLg),
                data:
                    (packs) => CategorySelectGrid(
                      entries: [
                        for (final pack in packs)
                          CategoryCardData(
                            cardKey: Key('pack_${pack.packId}'),
                            title: pack.titleTh,
                            imagePath: pack.pairs.first.image,
                            onTap:
                                () => context.push(
                                  '$kRouteMemoryGame/${pack.packId}',
                                ),
                          ),
                      ],
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
