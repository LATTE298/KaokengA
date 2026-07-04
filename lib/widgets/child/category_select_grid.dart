import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/typography.dart';
import 'pressable_child_card.dart';

// ตารางเลือกหมวด 3×2 — ใช้ร่วมกันระหว่าง Module B (เลือกแพ็คจับคู่ภาพ) และ
// Module C (เลือกหมวดเกมตอบคำถาม) ให้สองหน้ามีหน้าตา/พฤติกรรมเดียวกันเป๊ะ
// (ความคงเส้นคงวาช่วยเด็กกลุ่มเป้าหมายจำรูปแบบการใช้งานได้)
class CategoryCardData {
  const CategoryCardData({
    required this.title,
    required this.imagePath,
    required this.onTap,
    this.cardKey,
  });

  final String title;

  /// รูปตัวอย่างของหมวด — โหลดไม่ได้จะ fallback เป็นไอคอนกลาง
  final String imagePath;
  final VoidCallback onTap;
  final Key? cardKey;
}

class CategorySelectGrid extends StatelessWidget {
  const CategorySelectGrid({super.key, required this.entries});

  final List<CategoryCardData> entries;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // แบ่งพื้นที่จริงเป็นตาราง 3 คอลัมน์ (กฎ responsive — CLAUDE.md ข้อ 3)
        const columns = 3;
        final rows = (entries.length / columns).ceil().clamp(1, 10);
        final cardWidth =
            (constraints.maxWidth - kInteractiveGapMin * (columns - 1)) /
            columns;
        final cardHeight =
            (constraints.maxHeight - kInteractiveGapMin * (rows - 1)) / rows;
        return GridView.count(
          crossAxisCount: columns,
          mainAxisSpacing: kInteractiveGapMin,
          crossAxisSpacing: kInteractiveGapMin,
          childAspectRatio: cardWidth / cardHeight,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final entry in entries)
              _CategoryCard(key: entry.cardKey, data: entry),
          ],
        );
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({super.key, required this.data});

  final CategoryCardData data;

  @override
  Widget build(BuildContext context) {
    return PressableChildCard(
      onTap: data.onTap,
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
                  child: Image.asset(
                    data.imagePath,
                    fit: BoxFit.contain,
                    errorBuilder:
                        (_, __, ___) => const Icon(
                          Icons.category_rounded,
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
              child: Text(data.title, style: kChildLabel, maxLines: 1),
            ),
          ],
        ),
      ),
    );
  }
}
