import 'package:flutter/material.dart';

/// Brand palette — mirrors the colors used on the landing page and mockups.
class AppColors {
  AppColors._();

  static const Color apricot = Color(0xFFEE9B4C);
  static const Color apricotSoft = Color(0xFFF8BF86);
  static const Color apricotInk = Color(0xFFC9762C);
  static const Color navy = Color(0xFF33475F);
  static const Color navyDeep = Color(0xFF22303F);
  static const Color mint = Color(0xFF4FAF8B);
  static const Color cream = Color(0xFFFCFAF7);
  static const Color creamDeep = Color(0xFFFFF8EF);
  static const Color line = Color(0xFFEEE4D6);
  static const Color muted = Color(0xFF7E8895);
  static const Color danger = Color(0xFFC85A4A);
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    fontFamily: 'Cairo',
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.apricot,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.apricot,
      secondary: AppColors.mint,
      surface: Colors.white,
      onSurface: AppColors.navy,
      error: AppColors.danger,
    ),
    scaffoldBackgroundColor: AppColors.cream,
  );

  final textTheme = base.textTheme
      .apply(bodyColor: AppColors.navy, displayColor: AppColors.navy)
      .copyWith(
        headlineSmall: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w900,
          color: AppColors.navy,
          height: 1.35,
        ),
        titleLarge: const TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w800,
          color: AppColors.navy,
        ),
        titleMedium: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.navy,
        ),
        bodyMedium: const TextStyle(
          fontSize: 14,
          height: 1.7,
          color: AppColors.navy,
        ),
        bodySmall: const TextStyle(
          fontSize: 12.5,
          height: 1.7,
          color: AppColors.muted,
        ),
        labelLarge: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      );

  return base.copyWith(
    textTheme: textTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.cream,
      surfaceTintColor: Colors.transparent,
      foregroundColor: AppColors.navy,
      centerTitle: false,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 19,
        fontWeight: FontWeight.w800,
        color: AppColors.navy,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(color: AppColors.muted, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      border: _border(AppColors.line),
      enabledBorder: _border(AppColors.line),
      focusedBorder: _border(AppColors.apricot, width: 1.6),
      errorBorder: _border(AppColors.danger),
      focusedErrorBorder: _border(AppColors.danger, width: 1.6),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.apricot,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(56),
        textStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 16.5,
          fontWeight: FontWeight.w800,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.navy,
        minimumSize: const Size.fromHeight(52),
        side: const BorderSide(color: AppColors.line),
        backgroundColor: Colors.white,
        textStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.apricotInk,
        textStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.navyDeep,
      contentTextStyle: const TextStyle(
        fontFamily: 'Cairo',
        fontSize: 13.5,
        color: Colors.white,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.creamDeep,
      height: 72,
      elevation: 0,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontFamily: 'Cairo',
          fontSize: 12,
          fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          color: selected ? AppColors.navy : AppColors.muted,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          size: 24,
          color: selected ? AppColors.apricotInk : AppColors.muted,
        );
      }),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.line, thickness: 1),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
    ),
  );
}

OutlineInputBorder _border(Color color, {double width = 1}) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: color, width: width),
    );
