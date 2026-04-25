import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/tts_strings_th.dart';
import '../../providers/content_providers.dart';
import '../../providers/tts_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/typography.dart';
import '../../widgets/child_back_button.dart';

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
              child: asyncPack.when(
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => Text('โหลดเกมไม่สำเร็จ', style: kTextLg),
                data:
                    (pack) => GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        ref.read(ttsServiceProvider).speak(kTtsMemoryStart);
                        context.push(kRouteMemoryGame);
                      },
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
