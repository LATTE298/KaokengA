import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

import '../theme/colors.dart';

// Success overlay (spec 04 §SuccessOverlayComponent).
// 60 particles, yellow + blue, auto-removes after 2.5s.
class SuccessOverlayComponent extends PositionComponent {
  SuccessOverlayComponent({required Vector2 gameSize})
    : super(size: gameSize, priority: 10);

  @override
  Future<void> onLoad() async {
    final rng = Random();
    add(
      ParticleSystemComponent(
        position: size / 2,
        particle: Particle.generate(
          count: 60,
          lifespan: 1.2,
          generator:
              (i) => AcceleratedParticle(
                acceleration: Vector2(0, 200),
                speed: Vector2(
                  rng.nextDouble() * 400 - 200,
                  rng.nextDouble() * -500 - 100,
                ),
                child: CircleParticle(
                  radius: rng.nextDouble() * 6 + 2,
                  paint:
                      Paint()
                        ..color = (i % 2 == 0) ? kYellowPrimary : kBluePrimary,
                ),
              ),
        ),
      ),
    );
    // Remove overlay after celebration window (spec 03 Flow 1 §9f).
    add(
      TimerComponent(
        period: 2.5,
        removeOnFinish: true,
        onTick: removeFromParent,
      ),
    );
  }
}
