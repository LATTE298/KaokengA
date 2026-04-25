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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _iconFor(widget.item.category),
              size: 48,
              color: kTextSecondary,
            ),
            const SizedBox(height: kSpace2),
            Text(widget.item.ttsWord, style: kChildLabel),
          ],
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
