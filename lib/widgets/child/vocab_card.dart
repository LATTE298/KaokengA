import 'package:flutter/material.dart';

import '../../models/vocabulary_item.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/typography.dart';
import 'pressable_child_card.dart';

class VocabCard extends StatefulWidget {
  const VocabCard({super.key, required this.item, required this.onTap});

  final VocabularyItem item;
  final Future<void> Function(VocabularyItem item) onTap;

  @override
  State<VocabCard> createState() => _VocabCardState();
}

class _VocabCardState extends State<VocabCard> {
  bool _active = false;

  Future<void> _onTap() async {
    await widget.onTap(widget.item);
    if (!mounted) return;
    setState(() => _active = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (mounted) setState(() => _active = false);
  }

  @override
  Widget build(BuildContext context) {
    return PressableChildCard(
      onTap: _onTap,
      scale: 1.08,
      duration: const Duration(milliseconds: 150),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: kRadiusMd,
          border: Border.all(
            color: _active ? kBluePrimary : kWarmBorder,
            width: _active ? 2 : 1,
          ),
          boxShadow: [_active ? kShadowMd : kShadowSm],
        ),
        // รูปจริงด้านบน + คำด้านล่าง — ย่อฟอนต์ตามขนาดช่องจริงของ grid
        // (กฎ responsive — CLAUDE.md ข้อ 3) รูปโหลดไม่ได้ fallback เป็นไอคอนหมวด
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cell = constraints.maxHeight;
            final labelStyle =
                cell < 110
                    ? kChildLabel.copyWith(fontSize: 18, height: 1.2)
                    : kChildLabel;
            return Padding(
              padding: const EdgeInsets.all(kSpace2),
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: kRadiusSm,
                      child: Image.asset(
                        widget.item.image,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => Icon(
                              iconForVocabCategory(widget.item.category),
                              size: (cell * 0.4).clamp(28.0, 48.0).toDouble(),
                              color: kTextSecondary,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: kSpace2),
                  // scaleDown กันคำยาวล้น/ถูกตัดคำ — คำศัพท์ต้องอ่านได้ครบเสมอ
                  // ยอมให้ตัวเล็กลงแทนการขึ้นบรรทัดใหม่หรือ ellipsis
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      widget.item.ttsWord,
                      style: labelStyle,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ไอคอนตัวแทนหมวดคำศัพท์ (6 หมวดจริงตาม vocabulary.json) — ใช้เป็น fallback
// ของ sound board (VocabCard) และเกมตอบคำถาม เมื่อไฟล์รูปโหลดไม่ได้
IconData iconForVocabCategory(String category) {
  switch (category) {
    case 'animals':
      return Icons.pets_rounded;
    case 'food':
      return Icons.restaurant_rounded;
    case 'drinks':
      return Icons.local_drink_rounded;
    case 'places':
      return Icons.place_rounded;
    case 'occupations':
      return Icons.badge_rounded;
    case 'everyday':
      return Icons.emoji_people_rounded;
    default:
      return Icons.label_rounded;
  }
}
