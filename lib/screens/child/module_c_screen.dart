import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/tts_strings_th.dart';
import '../../models/vocabulary_item.dart';
import '../../providers/content_providers.dart';
import '../../providers/tts_provider.dart';
import '../../services/haptic_service.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/typography.dart';
import '../../widgets/child_back_button.dart';

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
              child: asyncItems.when(
                loading: () => const Center(child: CircularProgressIndicator()),
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
                      itemBuilder: (context, i) => _VocabCard(item: items[i]),
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

class _VocabCard extends ConsumerStatefulWidget {
  const _VocabCard({required this.item});
  final VocabularyItem item;

  @override
  ConsumerState<_VocabCard> createState() => _VocabCardState();
}

class _VocabCardState extends ConsumerState<_VocabCard> {
  bool _active = false;
  bool _pressed = false;

  void _onTap() async {
    HapticService.tapLight();
    await ref.read(ttsServiceProvider).cancel(); // cancel prev per spec 08
    ref.read(ttsServiceProvider).speak(widget.item.ttsWord);
    setState(() => _active = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (mounted) setState(() => _active = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        _onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 1.08 : 1.0,
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
