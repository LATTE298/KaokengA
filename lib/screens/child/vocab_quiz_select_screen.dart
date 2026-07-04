import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/app_types.dart';
import '../../models/vocabulary_item.dart';
import '../../providers/content_providers.dart';
import '../../routes/app_routes.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/typography.dart';
import '../../widgets/child_back_button.dart';
import '../../widgets/child/category_select_grid.dart';
import '../../widgets/child/child_async_view.dart';

// หน้าเลือกหมวดของเกมตอบคำถาม (Module C) — ตาราง 6 หมวดหน้าตาเดียวกับหน้า
// เลือกแพ็คของเกมจับคู่ภาพ เลือกแล้วเข้า quiz เฉพาะคำในหมวดนั้น
class VocabQuizSelectScreen extends ConsumerWidget {
  const VocabQuizSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncItems = ref.watch(vocabularyProvider);

    return Scaffold(
      backgroundColor: kWarmWhite,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              // ซ้ายพ้นปุ่มย้อนกลับที่ลอยมุมบนซ้าย (8 + 64 = 72)
              padding: const EdgeInsets.fromLTRB(
                kTouchTargetMin + kSpace4,
                kSpace6,
                kSpace6,
                kSpace5,
              ),
              child: ChildAsyncView(
                value: asyncItems,
                loading: const Center(child: CircularProgressIndicator()),
                error: (_, __) => Text('โหลดเกมไม่สำเร็จ', style: kTextLg),
                data: (items) {
                  final entries = [
                    for (final category in kVocabCategories)
                      if (_firstOf(items, category) != null)
                        CategoryCardData(
                          cardKey: Key('quiz_cat_$category'),
                          title: kVocabCategoryTitles[category] ?? category,
                          imagePath: _firstOf(items, category)!.image,
                          onTap:
                              () => context.push('$kRouteVocabQuiz/$category'),
                        ),
                  ];
                  return CategorySelectGrid(entries: entries);
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

VocabularyItem? _firstOf(List<VocabularyItem> items, String category) {
  for (final item in items) {
    if (item.category == category) return item;
  }
  return null;
}
