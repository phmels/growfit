import 'package:flutter/material.dart';

class AppColors {
  // ── Backgrounds ────────────────────────────────────────────────────────────
  static const bg      = Color(0xFF0A0A0F); // fundo principal
  static const surface = Color(0xFF12121A); // cards, hero
  static const card    = Color(0xFF1A1A26); // cards secundários

  // ── Accent ─────────────────────────────────────────────────────────────────
  static const primary  = Color(0xFFC8F135); // verde-limão — ações principais
  static const accent2  = Color(0xFF7B5CFF); // roxo — gradiente avatar

  // ── Texto ──────────────────────────────────────────────────────────────────
  static const textLight = Color(0xFFF0F0F5); // texto principal
  static const textMuted = Color(0xFF6B6B80); // texto secundário/placeholders

  // ── Feedback ───────────────────────────────────────────────────────────────
  static const danger  = Color(0xFFFF4D6D); // vermelho — ações destrutivas
  static const border  = Color(0x12FFFFFF); // borda sutil (7% branco)

  // ── Aliases para manter compatibilidade com código existente ───────────────
  /// Use [primary] no lugar de [textDark] em telas com fundo escuro.
  static const textDark = textLight;
  static const secondary = surface;

  /// Atalho para [textMuted], usado em widgets internos.
  static const muted = textMuted;
}

class AppTextStyles {
  static const title = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textLight,
  );

  static const subtitle = TextStyle(
    fontSize: 14,
    color: AppColors.textMuted,
  );

  static const button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.bg, // texto escuro sobre botão verde-limão
  );

  static const label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 2,
    color: AppColors.primary,
  );

  static const sectionLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 2,
    color: AppColors.textMuted,
  );
}

final appTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.bg,

  // ── AppBar ─────────────────────────────────────────────────────────────────
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.bg,
    foregroundColor: AppColors.textLight,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: AppColors.primary,
      letterSpacing: 1.5,
    ),
  ),

  // ── Cores base do Material ─────────────────────────────────────────────────
  colorScheme: const ColorScheme.dark(
    primary:   AppColors.primary,
    secondary: AppColors.accent2,
    surface:   AppColors.surface,
    error:     AppColors.danger,
    onPrimary: AppColors.bg,
    onSecondary: AppColors.textLight,
    onSurface: AppColors.textLight,
    onError:   AppColors.textLight,
  ),

  // ── Cards ──────────────────────────────────────────────────────────────────
  cardTheme: CardThemeData(
    color: AppColors.card,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: const BorderSide(color: AppColors.border),
    ),
    margin: const EdgeInsets.symmetric(vertical: 6),
  ),

  // ── Botões ─────────────────────────────────────────────────────────────────
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.bg,
      textStyle: AppTextStyles.button,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      elevation: 0,
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),
  ),

  // ── FAB ────────────────────────────────────────────────────────────────────
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.bg,
    elevation: 0,
  ),

  // ── SnackBar ───────────────────────────────────────────────────────────────
  snackBarTheme: SnackBarThemeData(
    backgroundColor: AppColors.surface,
    contentTextStyle: const TextStyle(color: AppColors.textLight),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),

  // ── Dialog ─────────────────────────────────────────────────────────────────
  dialogTheme: DialogThemeData(
    backgroundColor: AppColors.surface,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    titleTextStyle: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: AppColors.textLight,
    ),
    contentTextStyle: const TextStyle(
      fontSize: 14,
      color: AppColors.textMuted,
    ),
  ),

  // ── Divider ────────────────────────────────────────────────────────────────
  dividerColor: AppColors.border,

  // ── Progress indicator ─────────────────────────────────────────────────────
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: AppColors.primary,
  ),

  // ── Icon ───────────────────────────────────────────────────────────────────
  iconTheme: const IconThemeData(color: AppColors.primary, size: 24),
);