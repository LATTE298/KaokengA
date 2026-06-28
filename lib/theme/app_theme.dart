import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';
import 'spacing.dart';
import 'typography.dart';

ThemeData buildAppTheme() {
  final base = ThemeData.light(useMaterial3: true);

  // สไตล์กลางสำหรับปุ่มหลักทุกปุ่มในแอป (ทั้งฝั่งเด็กและผู้ปกครอง) — บังคับขนาดกดขั้นต่ำ
  // kTouchTargetMin (64dp) มุมโค้งนุ่ม และตัวอักษรขนาดใหญ่อ่านง่าย (spec 1.3)
  // เดิมแต่ละหน้าจอต้องเซ็ต FilledButton.styleFrom(...) ซ้ำๆเองทุกที่ (เช่นใน popup ผลการเล่น
  // ของทั้ง Module A และ Module B) ย้ายมารวมไว้ที่นี่ที่เดียว ทำให้ทุกปุ่มสม่ำเสมอกันโดย
  // อัตโนมัติ และยังเขียนปุ่มใหม่ในอนาคตได้สั้นลงโดยไม่ต้องก็อปสไตล์ซ้ำ
  final filledButtonStyle = FilledButton.styleFrom(
    backgroundColor: kYellowPrimary,
    foregroundColor: kTextPrimary,
    disabledBackgroundColor: kDisabledSurface,
    disabledForegroundColor: kDisabledText,
    minimumSize: const Size(120, kTouchTargetMin),
    padding: const EdgeInsets.symmetric(
      horizontal: kSpace6,
      vertical: kSpace3,
    ),
    shape: RoundedRectangleBorder(borderRadius: kRadiusMd),
    textStyle: kButtonLabel,
  );

  final outlinedButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: kTextPrimary,
    minimumSize: const Size(120, kTouchTargetMin),
    padding: const EdgeInsets.symmetric(
      horizontal: kSpace6,
      vertical: kSpace3,
    ),
    side: const BorderSide(color: kWarmBorder, width: 1.5),
    shape: RoundedRectangleBorder(borderRadius: kRadiusMd),
    textStyle: kButtonLabel.copyWith(fontWeight: FontWeight.w600),
  );

  final textButtonStyle = TextButton.styleFrom(
    foregroundColor: kBlueDark,
    minimumSize: const Size(88, kTouchTargetMin),
    padding: const EdgeInsets.symmetric(
      horizontal: kSpace4,
      vertical: kSpace3,
    ),
    textStyle: kTextMd.copyWith(fontWeight: FontWeight.w600),
  );

  return base.copyWith(
    colorScheme: const ColorScheme.light(
      primary: kYellowPrimary,
      onPrimary: kTextPrimary,
      secondary: kBluePrimary,
      onSecondary: Colors.white,
      surface: kWarmWhite,
      onSurface: kTextPrimary,
      error: kError,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: kWarmWhite,
    textTheme: GoogleFonts.sarabunTextTheme(
      base.textTheme,
    ).apply(bodyColor: kTextPrimary, displayColor: kTextPrimary),
    appBarTheme: AppBarTheme(
      backgroundColor: kWarmWhite,
      foregroundColor: kTextPrimary,
      elevation: 0,
      titleTextStyle: kTextLg,
    ),
    cardTheme: CardThemeData(
      color: kWarmSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: kRadiusMd,
        side: const BorderSide(color: kWarmBorder, width: 1.0),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(style: filledButtonStyle),
    outlinedButtonTheme: OutlinedButtonThemeData(style: outlinedButtonStyle),
    textButtonTheme: TextButtonThemeData(style: textButtonStyle),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kWarmSurface,
      border: OutlineInputBorder(
        borderRadius: kRadiusMd,
        borderSide: const BorderSide(color: kWarmBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: kRadiusMd,
        borderSide: const BorderSide(color: kWarmBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: kRadiusMd,
        borderSide: const BorderSide(color: kBluePrimary, width: 2),
      ),
      labelStyle: kTextSm,
      hintStyle: kTextSm.copyWith(color: kTextHint),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.selected) ? kBluePrimary : kWarmMuted,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.selected) ? kBlueLight : kWarmBorder,
      ),
    ),
  );
}