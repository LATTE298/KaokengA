import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/typography.dart';
import 'pressable_child_card.dart';

class ModuleCard extends StatelessWidget {
  const ModuleCard({
    super.key,
    required this.label,
    required this.description,
    required this.icon,
    required this.background,
    required this.onTap,
  });

  final String label;
  final String description;
  final IconData icon;
  final Color background;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cardSize = (width / 3 - kSpace8).clamp(120.0, 240.0);

    return PressableChildCard(
      onTap: onTap,
      playClickSound: true,
      child: Container(
        width: cardSize,
        height: cardSize * 1.2,
        padding: const EdgeInsets.all(kSpace4),
        decoration: BoxDecoration(
          color: background,
          borderRadius: kRadiusLg,
          boxShadow: const [kShadowMd],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: kTextPrimary),
            const SizedBox(height: kSpace4),
            Text(label, style: kTextLg, textAlign: TextAlign.center),
            const SizedBox(height: kSpace2),
            Text(
              description,
              style: kTextSm,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
