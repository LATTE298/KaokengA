import 'dart:math';

import 'package:daily_life/screens/parent/parent_gate_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('generateParentGateProblem: เลขสองหลักทั้งคู่ + ผลรวมไม่เกิน 100', () {
    final rng = Random(42);
    for (var i = 0; i < 500; i++) {
      final p = generateParentGateProblem(rng);
      expect(p.a, inInclusiveRange(10, 89));
      expect(p.b, inInclusiveRange(10, 89));
      expect(p.answer, p.a + p.b);
      expect(p.answer, lessThanOrEqualTo(100));
    }
  });
}
