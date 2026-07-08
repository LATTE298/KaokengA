import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/family_card.dart';
import '../../providers/family_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/typography.dart';
import '../../widgets/orientation_lock.dart';

// หน้าจัดการ "คลังครอบครัว" ของผู้ปกครอง (เฟส 2.1) — เพิ่ม/ลบการ์ด (รูปคนในบ้าน
// + คำตอบ + ตัวลวงที่กำหนดเอง) เก็บ offline ใน Hive. เด็กเอาไปเล่นเกมทายว่าใครเป็นใคร
class FamilyManagerScreen extends ConsumerWidget {
  const FamilyManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(familyCardsProvider);

    return OrientationLock(
      portrait: true,
      child: Scaffold(
        backgroundColor: kWarmWhite,
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'กลับ',
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(kRouteDashboard);
              }
            },
          ),
          title: const Text('คลังครอบครัว'),
        ),
        body: cardsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error:
              (_, __) => Center(child: Text('โหลดไม่สำเร็จ', style: kTextMd)),
          data:
              (cards) =>
                  cards.isEmpty
                      ? const _EmptyState()
                      : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          kSpace6,
                          kSpace6,
                          kSpace6,
                          kSpace12 + kSpace10, // เว้นพื้นที่ให้ปุ่มลอยด้านล่าง
                        ),
                        itemCount: cards.length,
                        separatorBuilder:
                            (_, __) => const SizedBox(height: kSpace3),
                        itemBuilder: (context, i) => _CardTile(card: cards[i]),
                      ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          key: const Key('family-add'),
          backgroundColor: kYellowPrimary,
          foregroundColor: kTextPrimary,
          onPressed:
              () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                backgroundColor: kWarmWhite,
                builder: (_) => const _AddFamilyCardSheet(),
              ),
          icon: const Icon(Icons.add_a_photo_rounded),
          label: const Text('เพิ่มคนในครอบครัว'),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kSpace8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.diversity_3_rounded, size: 72, color: kWarmMuted),
            const SizedBox(height: kSpace4),
            Text(
              'ยังไม่มีคนในครอบครัว',
              style: kTextLg,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: kSpace2),
            Text(
              'กดปุ่ม "เพิ่มคนในครอบครัว" ใส่รูปพ่อ แม่ พี่ หรือคนที่น้องรู้จัก '
              'แล้วน้องจะได้เล่นเกมทายว่าใครเป็นใคร',
              style: kTextSm.copyWith(color: kTextSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CardTile extends ConsumerWidget {
  const _CardTile({required this.card});

  final FamilyCard card;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(kSpace3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: kRadiusMd,
        border: Border.all(color: kWarmBorder),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: kRadiusSm,
            child: Image.memory(
              card.imageBytes,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: kSpace4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(card.answer, style: kTextMd),
                const SizedBox(height: 2),
                Text(
                  'ตัวเลือก: ${card.distractors.join(", ")}',
                  style: kTextXs.copyWith(color: kTextSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            key: Key('family-delete-${card.id}'),
            tooltip: 'ลบ',
            icon: const Icon(Icons.delete_outline_rounded, color: kError),
            onPressed:
                () =>
                    ref.read(familyCardRepositoryProvider).deleteCard(card.id),
          ),
        ],
      ),
    );
  }
}

// ฟอร์มเพิ่มการ์ด — เลือกรูป + พิมพ์คำตอบ + ตัวลวง 2 อัน (ต้องต่างกันทั้งหมด)
class _AddFamilyCardSheet extends ConsumerStatefulWidget {
  const _AddFamilyCardSheet();

  @override
  ConsumerState<_AddFamilyCardSheet> createState() =>
      _AddFamilyCardSheetState();
}

class _AddFamilyCardSheetState extends ConsumerState<_AddFamilyCardSheet> {
  Uint8List? _imageBytes;
  final _answerController = TextEditingController();
  final _distractor1Controller = TextEditingController();
  final _distractor2Controller = TextEditingController();
  bool _saving = false;
  bool _randomMode = false; // เปิด = สุ่มตัวลวงจากสมาชิกคนอื่นตอนเล่น
  String? _error;

  @override
  void dispose() {
    _answerController.dispose();
    _distractor1Controller.dispose();
    _distractor2Controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final bytes =
        await ref.read(familyCardRepositoryProvider).pickAndResizeImage();
    if (bytes != null && mounted) setState(() => _imageBytes = bytes);
  }

  Future<void> _save() async {
    final answer = _answerController.text.trim();
    final d1 = _distractor1Controller.text.trim();
    final d2 = _distractor2Controller.text.trim();

    if (_imageBytes == null) {
      setState(() => _error = 'เลือกรูปก่อนนะครับ');
      return;
    }
    if (answer.isEmpty) {
      setState(() => _error = 'กรอกคำตอบ (นี่คือใคร) ก่อนนะครับ');
      return;
    }
    if (!_randomMode) {
      if (d1.isEmpty || d2.isEmpty) {
        setState(
          () => _error = 'กรอกตัวเลือกลวงให้ครบ 2 อัน (หรือเปิดโหมดสุ่ม)',
        );
        return;
      }
      if ({answer, d1, d2}.length < 3) {
        setState(() => _error = 'คำตอบและตัวเลือกต้องไม่ซ้ำกัน');
        return;
      }
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    await ref
        .read(familyCardRepositoryProvider)
        .addCard(
          imageBytes: _imageBytes!,
          answer: answer,
          distractors: _randomMode ? const [] : [d1, d2],
          randomChoices: _randomMode,
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(kSpace6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: Text('เพิ่มคนในครอบครัว', style: kTextLg)),
                  // ปุ่มลูกเต๋า = สลับโหมดสุ่มตัวเลือก (ขอบเขียว=เปิด, แดง=ปิด)
                  GestureDetector(
                    key: const Key('family-dice-toggle'),
                    onTap:
                        _saving
                            ? null
                            : () => setState(() {
                              _randomMode = !_randomMode;
                              _error = null;
                            }),
                    child: Container(
                      padding: const EdgeInsets.all(kSpace2),
                      decoration: BoxDecoration(
                        color: _randomMode ? kSuccessLight : kErrorLight,
                        borderRadius: kRadiusMd,
                        border: Border.all(
                          color: _randomMode ? kSuccess : kError,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.casino_rounded,
                        color: _randomMode ? kSuccess : kError,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: kSpace2),
              Text(
                _randomMode
                    ? 'โหมดสุ่มเปิด: ตัวเลือกลวงจะสุ่มจากสมาชิกคนอื่นให้ตอนเล่น'
                    : 'กดลูกเต๋าเพื่อสุ่มตัวเลือกลวงจากสมาชิกคนอื่นอัตโนมัติ',
                style: kTextXs.copyWith(color: kTextSecondary),
              ),
              const SizedBox(height: kSpace4),

              // เลือกรูป + พรีวิว
              Center(
                child: GestureDetector(
                  key: const Key('family-pick-image'),
                  onTap: _saving ? null : _pickImage,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: kWarmSurface,
                      borderRadius: kRadiusMd,
                      border: Border.all(color: kWarmBorder, width: 1.5),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child:
                        _imageBytes == null
                            ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.add_a_photo_rounded,
                                  size: 32,
                                  color: kWarmMuted,
                                ),
                                const SizedBox(height: kSpace1),
                                Text('เลือกรูป', style: kTextXs),
                              ],
                            )
                            : Image.memory(_imageBytes!, fit: BoxFit.cover),
                  ),
                ),
              ),
              const SizedBox(height: kSpace5),

              _field(
                key: const Key('family-answer'),
                controller: _answerController,
                label: 'นี่คือใคร (คำตอบที่ถูก)',
                hint: 'เช่น แม่',
              ),
              const SizedBox(height: kSpace4),
              _field(
                key: const Key('family-distractor-1'),
                controller: _distractor1Controller,
                label: 'ตัวเลือกลวง 1',
                hint: _randomMode ? 'สุ่มให้อัตโนมัติ' : 'เช่น พ่อ',
                enabled: !_randomMode,
              ),
              const SizedBox(height: kSpace4),
              _field(
                key: const Key('family-distractor-2'),
                controller: _distractor2Controller,
                label: 'ตัวเลือกลวง 2',
                hint: _randomMode ? 'สุ่มให้อัตโนมัติ' : 'เช่น พี่',
                enabled: !_randomMode,
              ),

              if (_error != null) ...[
                const SizedBox(height: kSpace3),
                Text(
                  _error!,
                  style: kTextSm.copyWith(color: kError),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: kSpace5),

              FilledButton(
                key: const Key('family-save'),
                onPressed: _saving ? null : _save,
                child:
                    _saving
                        ? const SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text('บันทึก'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required Key key,
    required TextEditingController controller,
    required String label,
    required String hint,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: kTextSm.copyWith(color: kTextPrimary)),
        const SizedBox(height: kSpace1),
        TextField(
          key: key,
          controller: controller,
          enabled: !_saving && enabled,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}
