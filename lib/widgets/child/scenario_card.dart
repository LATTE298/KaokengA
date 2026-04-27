import 'package:flutter/material.dart';

import '../../models/scenario_config.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/typography.dart';
import 'pressable_child_card.dart';

class ScenarioCard extends StatelessWidget {
  const ScenarioCard({super.key, required this.summary, required this.onTap});

  final ScenarioSummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableChildCard(
      onTap: onTap,
      child: Container(
        width: 220,
        height: 280,
        decoration: BoxDecoration(
          color: kWarmSurface,
          borderRadius: kRadiusMd,
          border: Border.all(color: kWarmBorder, width: 1.5),
          boxShadow: const [kShadowSm],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
                child: Container(
                  color: kYellowLight,
                  child: Image.asset(
                    summary.thumbnailUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.image_rounded,
                          size: 72,
                          color: kYellowDark,
                        ),
                      );
                    },
                  ),
                ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(kSpace4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      summary.titleTh,
                      style: kChildLabel,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: kSpace2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: kSpace3,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: kBlueLight,
                        borderRadius: kRadiusFull,
                      ),
                      child: Text(
                        summary.category,
                        style: kTextXs.copyWith(color: kBlueDark),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
