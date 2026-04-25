import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';
import 'spacing.dart';
import 'typography.dart';

ThemeData buildAppTheme() {
  final base = ThemeData.light(useMaterial3: true);
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
