import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../theme/colors.dart';

// Rendered in place of a missing sprite — a rounded warm-yellow rectangle with
// the item's Thai label centred. Temporary placeholder until real .webp assets
// land in assets/images/.
class PlaceholderComponent extends PositionComponent {
  PlaceholderComponent({
    required super.size,
    required this.label,
    this.fill = kYellowLight,
    this.border = kYellowDark,
    super.position,
    super.priority,
  });

  final String label;
  final Color fill;
  final Color border;

  late final TextPainter _textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )
    ..text = TextSpan(
      text: label,
      style: const TextStyle(
        color: kTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );

  @override
  void render(Canvas canvas) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(16),
    );
    canvas
      ..drawRRect(rect, Paint()..color = fill)
      ..drawRRect(
        rect,
        Paint()
          ..color = border
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

    _textPainter.layout(maxWidth: size.x - 16);
    _textPainter.paint(
      canvas,
      Offset(
        (size.x - _textPainter.width) / 2,
        (size.y - _textPainter.height) / 2,
      ),
    );
  }
}
