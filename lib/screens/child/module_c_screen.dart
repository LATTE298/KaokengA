import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../routes/app_routes.dart';
import '../../theme/colors.dart';
import '../../widgets/child/paper_background.dart';
import '../../theme/spacing.dart';
import '../../widgets/child_back_button.dart';
import '../../widgets/child/module_card.dart';

// Module C hub — เดิมเป็น sound board ทั้งหน้า (ย้ายไป sound_board_screen.dart)
// ตอนนี้แยกเป็น 2 โหมดตามเอกสารข้อเสนอ: ฟังเสียงคำศัพท์ (เรียนรู้) และ
// เกมตอบคำถาม (ทดสอบ + เก็บข้อมูลถูก/ผิดรายคำให้ dashboard เฟส 2.2)
class ModuleCScreen extends ConsumerWidget {
  const ModuleCScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: kWarmWhite,
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(child: PaperBackground()),
            Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // แบ่งความกว้างจริงให้การ์ด 2 ใบ + ช่องว่างกลาง (กฎ responsive
                  // ข้อ 3 — แบบเดียวกับ mode_select ที่หาร 3)
                  final cardWidth =
                      ((constraints.maxWidth -
                                  kInteractiveGapMin -
                                  kSpace6 * 2) /
                              2)
                          .clamp(140.0, 340.0)
                          .toDouble();
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ModuleCard(
                        label: 'ฟังเสียงคำศัพท์',
                        description: 'แตะรูป ฟังเสียงอ่านคำ',
                        icon: Icons.volume_up_rounded,
                        background: kBlueLight,
                        cardWidth: cardWidth,
                        onTap: () => context.push(kRouteSoundBoard),
                      ),
                      const SizedBox(width: kInteractiveGapMin),
                      ModuleCard(
                        label: 'เกมตอบคำถาม',
                        description: 'ฟังเสียงแล้วเลือกการ์ดให้ถูก',
                        icon: Icons.quiz_rounded,
                        background: kYellowLight,
                        cardWidth: cardWidth,
                        onTap: () => context.push(kRouteVocabQuiz),
                      ),
                    ],
                  );
                },
              ),
            ),
            const Positioned(top: 8, left: 8, child: ChildBackButton()),
          ],
        ),
      ),
    );
  }
}
