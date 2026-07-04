import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/memory_pack.dart';
import '../../providers/content_providers.dart';
import '../../routes/app_routes.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/typography.dart';
import '../../widgets/child_back_button.dart';
import '../../widgets/child/child_async_view.dart';
import '../../widgets/child/pressable_child_card.dart';

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
                    (packs) => LayoutBuilder(
                      builder: (context, constraints) {
                        // แบ่งพื้นที่จริงเป็นตาราง 3×2 (กฎ responsive ข้อ 3)
                        const columns = 3;
                        final rows = (packs.length / columns).ceil();
                        final cardWidth =
                            (constraints.maxWidth -
                                kInteractiveGapMin * (columns - 1)) /
                            columns;
                        final cardHeight =
                            (constraints.maxHeight -
                                kInteractiveGapMin * (rows - 1)) /
                            rows;
                        return GridView.count(
                          crossAxisCount: columns,
                          mainAxisSpacing: kInteractiveGapMin,
                          crossAxisSpacing: kInteractiveGapMin,
                          childAspectRatio: cardWidth / cardHeight,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            for (final pack in packs)
                              _PackCard(
                                key: Key('pack_${pack.packId}'),
                                pack: pack,
                                onTap:
                                    () => context.push(
                                      '$kRouteMemoryGame/${pack.packId}',
                                    ),
                              ),
                          ],
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

class _PackCard extends StatelessWidget {
  const _PackCard({super.key, required this.pack, required this.onTap});

  final MemoryPack pack;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableChildCard(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(kSpace3),
        decoration: BoxDecoration(
          color: kBlueLight,
          borderRadius: kRadiusLg,
          boxShadow: const [kShadowMd],
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: kRadiusMd,
                child: Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.all(kSpace2),
                  // รูปตัวอย่าง = คู่แรกของหมวด (โหลดไม่ได้ fallback ไอคอนกลาง)
                  child: Image.asset(
                    pack.pairs.first.image,
                    fit: BoxFit.contain,
                    errorBuilder:
                        (_, __, ___) => const Icon(
                          Icons.grid_view_rounded,
                          size: 48,
                          color: kBlueDark,
                        ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: kSpace2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(pack.titleTh, style: kChildLabel, maxLines: 1),
            ),
          ],
        ),
      ),
    );
  }
}
