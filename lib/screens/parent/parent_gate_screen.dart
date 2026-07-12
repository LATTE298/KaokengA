import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/tts_strings_th.dart';
import '../../routes/app_routes.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/typography.dart';
import '../../widgets/orientation_lock.dart';

// โจทย์บวกเลขสองหลัก (10-89) ผลรวมไม่เกิน 100 — ด่านกันเด็ก (เด็กเล็กบวกเลขสองหลัก
// ไม่ได้ ผู้ปกครองทำได้). แยกเป็น logic pure เพื่อ test ตรงๆ
class ParentGateProblem {
  const ParentGateProblem(this.a, this.b);

  final int a;
  final int b;

  int get answer => a + b;
}

/// สุ่มโจทย์ a + b โดย a,b เป็นเลขสองหลัก (10-89) และผลรวม ≤ 100
ParentGateProblem generateParentGateProblem([Random? random]) {
  final rng = random ?? Random();
  final a = 10 + rng.nextInt(71); // 10..80
  // b เป็นสองหลักและทำให้ผลรวมไม่เกิน 100
  final maxB = (100 - a).clamp(10, 89);
  final b = 10 + rng.nextInt(maxB - 10 + 1);
  return ParentGateProblem(a, b);
}

// Parent gate (spec 02) — ยืนยันผู้ปกครองด้วยการบวกเลข แทนปุ่มกดยืนยันเปล่าๆ
class ParentGateScreen extends ConsumerStatefulWidget {
  const ParentGateScreen({super.key});

  @override
  ConsumerState<ParentGateScreen> createState() => _ParentGateScreenState();
}

class _ParentGateScreenState extends ConsumerState<ParentGateScreen> {
  final _controller = TextEditingController();
  late ParentGateProblem _problem = generateParentGateProblem();
  bool _wrong = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final input = int.tryParse(_controller.text.trim());
    if (input != null && input == _problem.answer) {
      _controller.clear();
      context.push(kRouteAuth);
      return;
    }
    // ตอบผิด — เปลี่ยนโจทย์ใหม่กันสุ่มเดา + แจ้งเตือน
    setState(() {
      _wrong = true;
      _problem = generateParentGateProblem();
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationLock(
      portrait: true,
      child: Scaffold(
        backgroundColor: kWarmWhite,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(kSpace6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    kParentGateTitle,
                    style: kTextXL,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: kSpace4),
                  Text(
                    'ยืนยันว่าคุณเป็นผู้ปกครอง โดยตอบผลบวกต่อไปนี้',
                    style: kTextMd.copyWith(color: kTextSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: kSpace8),
                  Text(
                    '${_problem.a} + ${_problem.b} = ?',
                    style: kTextXL.copyWith(
                      fontWeight: FontWeight.w800,
                      color: kBlueDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: kSpace4),
                  TextField(
                    key: const Key('parent-gate-answer'),
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textAlign: TextAlign.center,
                    style: kTextLg,
                    autofocus: true,
                    onSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      hintText: 'ใส่คำตอบ',
                      errorText: _wrong ? 'ยังไม่ถูก ลองอีกครั้ง' : null,
                      filled: true,
                      fillColor: kWarmSurface,
                      border: OutlineInputBorder(
                        borderRadius: kRadiusMd,
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: kSpace6),
                  FilledButton(
                    key: const Key('parent-gate-submit'),
                    onPressed: _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: kYellowPrimary,
                      foregroundColor: kTextPrimary,
                      padding: const EdgeInsets.symmetric(vertical: kSpace4),
                      shape: RoundedRectangleBorder(borderRadius: kRadiusMd),
                    ),
                    child: Text(kParentGateEnter, style: kTextLg),
                  ),
                  const SizedBox(height: kSpace4),
                  TextButton(
                    // กลับไปหน้าที่กดเข้ามา (home หรือ mode-select)
                    onPressed: () => context.go(parentAreaOrigin),
                    child: Text(
                      'กลับ',
                      style: kTextMd.copyWith(color: kTextSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
