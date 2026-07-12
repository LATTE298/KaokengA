import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/tts_strings_th.dart';
import '../../providers/content_providers.dart';
import '../../providers/tts_provider.dart';
import '../../services/haptic_service.dart';
import '../../theme/colors.dart';
import '../../widgets/child/paper_background.dart';
import '../../theme/spacing.dart';
import '../../theme/typography.dart';
import '../../widgets/child_back_button.dart';
import '../../widgets/child/child_async_view.dart';
import '../../widgets/child/vocab_card.dart';

// Sound board (spec 02 §ModuleCScreen, spec 03 Flow 3) — โหมด "ฟังเสียงคำศัพท์"
// grid 5 คอลัมน์ เลื่อนแนวตั้ง (คลังคำจริง 6 หมวด 90 คำ) แตะเพื่อฟัง ไม่มี auto-play
// เดิมเป็นตัว ModuleCScreen ทั้งหน้า ย้ายมาที่นี่เมื่อ Module C กลายเป็น hub
class SoundBoardScreen extends ConsumerStatefulWidget {
  const SoundBoardScreen({super.key});

  @override
  ConsumerState<SoundBoardScreen> createState() => _SoundBoardScreenState();
}

class _SoundBoardScreenState extends ConsumerState<SoundBoardScreen> {
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
            const Positioned.fill(child: PaperBackground()),
            Padding(
              // ซ้ายต้องพ้นปุ่มย้อนกลับที่ลอยมุมบนซ้าย (8 + 64 = 72) — เดิม kSpace12 (48)
              // ทำให้ปุ่มทับมุมการ์ดคอลัมน์แรก แตะมุมนั้นแล้วโดนปุ่มแทนการ์ด
              padding: const EdgeInsets.fromLTRB(
                kTouchTargetMin + kSpace4,
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
