import 'package:flutter/material.dart';

// 8px base grid
const double kSpace1 = 4.0;
const double kSpace2 = 8.0;
const double kSpace3 = 12.0;
const double kSpace4 = 16.0;
const double kSpace5 = 20.0;
const double kSpace6 = 24.0;
const double kSpace8 = 32.0;
const double kSpace10 = 40.0;
const double kSpace12 = 48.0;
const double kSpace16 = 64.0;

// Border radius
final BorderRadius kRadiusSm = BorderRadius.circular(8);
final BorderRadius kRadiusMd = BorderRadius.circular(16);
final BorderRadius kRadiusLg = BorderRadius.circular(24);
final BorderRadius kRadiusXl = BorderRadius.circular(32);
final BorderRadius kRadiusFull = BorderRadius.circular(999);

// Shadows
const BoxShadow kShadowSm = BoxShadow(
  color: Color(0x20B97C00),
  blurRadius: 8,
  offset: Offset(0, 2),
);

const BoxShadow kShadowMd = BoxShadow(
  color: Color(0x30B97C00),
  blurRadius: 16,
  offset: Offset(0, 4),
);

const BoxShadow kShadowLg = BoxShadow(
  color: Color(0x40B97C00),
  blurRadius: 24,
  offset: Offset(0, 8),
);

// Animation
const Duration kDurationFast = Duration(milliseconds: 150);
const Duration kDurationNormal = Duration(milliseconds: 300);
const Duration kDurationSlow = Duration(milliseconds: 500);

const Curve kCurveDefault = Curves.easeInOut;
const Curve kCurveSpring = Curves.elasticOut;
const Curve kCurvePop = Curves.easeOutBack;
