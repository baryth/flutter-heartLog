import 'package:flutter/material.dart';

/// Central color palette for HeartLog — "Indigo Dusk" theme.
///
/// Single source of truth for every brand color in the app. To re-theme,
/// change the values here only.
abstract class AppColors {
  // ── Surfaces & text ──────────────────────────────────────────
  static const Color bg = Color(0xFFF4F3FB);
  static const Color textPrimary = Color(0xFF2A2A4A);
  static const Color textSecondary = Color(0xFF8786AE);

  // ── Brand ────────────────────────────────────────────────────
  static const Color primary = Color(0xFF5A5FD0); // buttons, seed, accents
  static const Color confirm = Color(0xFF93D7C0);

  // ── Gear knobs / metric series ───────────────────────────────
  static const Color gearSystolic = Color(0xFF9FA3F2);
  static const Color gearDiastolic = Color(0xFF5A5FD0);
  static const Color gearPulse = Color(0xFFFF7BA6);

  // ── Blood-pressure status ramp (normal → high) ───────────────
  static const Color statusNormal = Color(0xFF86D0B6);
  static const Color statusElevated = Color(0xFFF4C870);
  static const Color statusStage1 = Color(0xFFF39E72);
  static const Color statusStage2 = Color(0xFFF0708F);

  // ── Supporting neutrals (harmonized with the cool palette) ───
  static const Color surfaceTint = Color(0xFFECEDFB); // light fills
  static const Color border = Color(0xFFE0DFEF); // hairlines, dividers
  static const Color disabledBg = Color(0xFFECEAF0);
  static const Color disabledFg = Color(0xFFC3C2D0);
}
