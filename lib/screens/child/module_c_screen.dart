import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/tts_strings_th.dart';
import '../../providers/content_providers.dart';
import '../../providers/tts_provider.dart';
import '../../services/haptic_service.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/typography.dart';
import '../../widgets/child_back_button.dart';
import '../../widgets/child/child_async_view.dart';
import '../../widgets/child/vocab_card.dart';

// Sound board (spec 02 §ModuleCScreen, spec 03 Flow 3).
// 5×6 grid of 30 vocabulary items; tap-to-hear, no auto-play.
class ModuleCScreen extends ConsumerStatefulWidget {
  const ModuleCScreen({super.key});

  @override
  ConsumerState<ModuleCScreen> createState() => _ModuleCScreenState();
}

class _ModuleCScreenState extends ConsumerState<ModuleCScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ttsServiceProvider).speak(kTtsSoundBoardStart);
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncItems = ref.watch(vocabularyProvider);

    return Scaffold(
      backgroundColor: kWarmWhite,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                kSpace12,
                kSpace10,
                kSpace6,
                kSpace6,
              ),
              child: ChildAsyncView(
                value: asyncItems,
                error:
                    (_, __) =>
                        Center(child: Text(kLabelModuleC, style: kTextXL)),
                data:
                    (items) => GridView.builder(
                      itemCount: items.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            mainAxisSpacing: kSpace3,
                            crossAxisSpacing: kSpace3,
                            childAspectRatio: 1.0,
                          ),
                      itemBuilder:
                          (context, i) => VocabCard(
                            item: items[i],
                            onTap: (item) async {
                              HapticService.tapLight();
                              await ref.read(ttsServiceProvider).cancel();
                              ref.read(ttsServiceProvider).speak(item.ttsWord);
                            },
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
