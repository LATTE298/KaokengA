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
        // ย่อไอคอน/ฟอนต์ตามขนาดช่องจริงของ grid (กฎ responsive — CLAUDE.md ข้อ 3)
        // ค่า fix เดิม (ไอคอน 48 + kChildLabel 22) ล้นช่องเมื่อจอแคบจนช่องเล็กกว่า ~100px
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cell = constraints.maxHeight;
            final iconSize = (cell * 0.4).clamp(28.0, 48.0).toDouble();
            final labelStyle =
                cell < 110
                    ? kChildLabel.copyWith(fontSize: 18, height: 1.2)
                    : kChildLabel;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _iconFor(widget.item.category),
                  size: iconSize,
                  color: kTextSecondary,
                ),
                const SizedBox(height: kSpace2),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: kSpace1),
                  // scaleDown กันคำยาว (เช่น "แปรงสีฟัน") ล้น/ถูกตัดคำ — คำศัพท์ต้อง
                  // อ่านได้ครบเสมอ ยอมให้ตัวเล็กลงแทนการขึ้นบรรทัดใหม่หรือ ellipsis
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      widget.item.ttsWord,
                      style: labelStyle,
                      maxLines: 1,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

IconData _iconFor(String category) {
  switch (category) {
    case 'animals':
      return Icons.pets_rounded;
    case 'food':
      return Icons.restaurant_rounded;
    case 'colours':
      return Icons.palette_rounded;
    case 'body':
      return Icons.accessibility_new_rounded;
    case 'household':
      return Icons.chair_rounded;
    default:
      return Icons.label_rounded;
  }
}
