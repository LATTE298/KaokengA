import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

// Thai-first font: Sarabun (loaded via google_fonts).
// Usage: `kTextLg` etc. are base styles; components may copyWith(color:) as needed.

TextStyle _sarabun({
  required double fontSize,
  required FontWeight fontWeight,
  Color color = kTextPrimary,
  double height = 1.4,
}) {
  return GoogleFonts.sarabun(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    height: height,
  );
}

TextStyle get kTextXL =>
    _sarabun(fontSize: 32, fontWeight: FontWeight.w700, height: 1.3);

TextStyle get kTextLg =>
    _sarabun(fontSize: 24, fontWeight: FontWeight.w600, height: 1.4);

TextStyle get kTextMd =>
    _sarabun(fontSize: 18, fontWeight: FontWeight.w500, height: 1.5);

TextStyle get kTextBase =>
    _sarabun(fontSize: 16, fontWeight: FontWeight.w400, height: 1.6);

TextStyle get kTextSm => _sarabun(
  fontSize: 14,
  fontWeight: FontWeight.w400,
  color: kTextSecondary,
  height: 1.5,
);

TextStyle get kTextXs => _sarabun(
  fontSize: 12,
  fontWeight: FontWeight.w400,
  color: kTextHint,
  height: 1.4,
);

// Larger labels for child-facing UI.
TextStyle get kChildLabel =>
    _sarabun(fontSize: 20, fontWeight: FontWeight.w600, height: 1.4);
