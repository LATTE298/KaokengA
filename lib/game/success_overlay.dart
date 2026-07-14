import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

import '../theme/colors.dart';

// Success overlay — confetti วงกลมสีฉลองตอนจบด่าน (Module A) เล่นพร้อมเสียง Kaokeng_congrat.
// ปรับปรุง 2026-07-14: burst หนาแน่นขึ้น (110 ชิ้น) + พาเลตต์หลากสีโทนแบรนด์ + จาง/ย่อขนาด
// นุ่มช่วงท้าย (ไม่หายวับ) + ผสมวงทึบ/วงขอบ/วงใหญ่มีไฮไลต์ขาวเงาวาว. พุ่งขึ้นเป็นน้ำพุแล้วตก
class SuccessOverlayComponent extends PositionComponent {
  SuccessOverlayComponent({required Vector2 gameSize})
    : super(size: gameSize, priority: 10);

  // พาเลตต์รื่นเริงในโทนแบรนด์ (ฟ้า-เหลืองหลัก + เขียว/ส้มอ่อนแต่งให้สดใส)
  static const _palette = <Color>[
    kYellowPrimary,
    kBluePrimary,
    kYellowAccent,
    kBlueLight,
    kSuccess,
    kError,
  ];

  @override
  Future<void> onLoad() async {
    final rng = Random();
    // จุดกำเนิด burst กลางจอ พุ่งขึ้น-กระจายออกแล้วตกตามแรงโน้มถ่วง
    final origin = Vector2(size.x / 2, size.y * 0.52);

    add(
      ParticleSystemComponent(
        position: origin,
        particle: Particle.generate(
          count: 110,
          lifespan: 1.8,
          generator: (i) {
            final color = _palette[rng.nextInt(_palette.length)];
            final radius = rng.nextDouble() * 7 + 3; // 3..10
            final isRing = rng.nextInt(5) == 0; // ~1 ใน 5 เป็นวงขอบ
            final glossy = !isRing && radius > 7; // วงทึบใหญ่ = มีไฮไลต์ขาว
            return AcceleratedParticle(
              acceleration: Vector2(0, 640), // แรงโน้มถ่วงให้ตกลง
              speed: Vector2(
                rng.nextDouble() * 720 - 360, // กระจายซ้าย-ขวากว้าง
                rng.nextDouble() * -640 - 180, // พุ่งขึ้น (แรงต่างกัน)
              ),
              child: ComputedParticle(
                renderer: (canvas, particle) {
                  final t = particle.progress; // 0..1
                  // ป๊อปโตเร็วช่วงแรก (0..0.18) แล้วค่อยๆ หดปลาย ๆ
                  final grow = (t / 0.18).clamp(0.0, 1.0);
                  final shrink =
                      1.0 - ((t - 0.6) / 0.4).clamp(0.0, 1.0) * 0.4;
                  final r = radius * grow * shrink;
                  // จางช่วงท้าย (0.55..1.0) แบบนุ่ม
                  final fade = 1.0 - ((t - 0.55) / 0.45).clamp(0.0, 1.0);
                  if (r <= 0.2 || fade <= 0) return;

                  if (isRing) {
                    canvas.drawCircle(
                      Offset.zero,
                      r,
                      Paint()
                        ..color = color.withValues(alpha: fade)
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = max(1.5, r * 0.32),
                    );
                    return;
                  }

                  canvas.drawCircle(
                    Offset.zero,
                    r,
                    Paint()..color = color.withValues(alpha: fade),
                  );
                  if (glossy) {
                    // ไฮไลต์ขาวมุมบนซ้าย ให้ดูเงาวาวเหมือนลูกโป่ง
                    canvas.drawCircle(
                      Offset(-r * 0.3, -r * 0.3),
                      r * 0.3,
                      Paint()
                        ..color = Colors.white.withValues(alpha: fade * 0.7),
                    );
                  }
                },
              ),
            );
          },
        ),
      ),
    );

    // ลบ overlay หลังหน้าต่างฉลอง (spec 03 Flow 1 §9f)
    add(
      TimerComponent(
        period: 2.5,
        removeOnFinish: true,
        onTick: removeFromParent,
      ),
    );
  }
}
