import 'package:flutter/material.dart';

/// The small set of design colors shared by the MyTasks Flutter screens.
abstract final class MyTasksColors {
  static const coral = Color(0xFFFF6B6B);
  static const coralInk = Color(0xFFB83E45);
  static const teal = Color(0xFF4ECDC4);
  static const tealInk = Color(0xFF176A65);
  static const butter = Color(0xFFFFE66D);
  static const cream = Color(0xFFFAF5EB);
  static const white = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF0E6D6);
  static const border = Color(0xFFEBDCC7);
  static const ink = Color(0xFF2D3436);
  static const inkMuted = Color(0xFF596367);
  static const overdue = Color(0xFFB3261E);

  static const effortGreens = <Color>[
    Color(0xFFC8E6C9),
    Color(0xFFA5D6A7),
    Color(0xFF81C784),
    Color(0xFF4CAF50),
    Color(0xFF2E7D32),
  ];
}

abstract final class MyTasksTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final background = isDark ? const Color(0xFF191A18) : MyTasksColors.cream;
    final surface = isDark ? const Color(0xFF252723) : MyTasksColors.white;
    final ink = isDark ? const Color(0xFFF7F1E7) : MyTasksColors.ink;
    final muted = isDark ? const Color(0xFFC8C1B5) : MyTasksColors.inkMuted;
    final border = isDark ? const Color(0xFF48463F) : MyTasksColors.border;
    final primary = isDark ? const Color(0xFFFF8580) : MyTasksColors.coral;
    final secondary = isDark ? const Color(0xFF77DAD2) : MyTasksColors.teal;
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: MyTasksColors.ink,
      primaryContainer: isDark
          ? const Color(0xFF583334)
          : const Color(0xFFFFE5E0),
      onPrimaryContainer: isDark ? const Color(0xFFFFE7E4) : MyTasksColors.ink,
      secondary: secondary,
      onSecondary: MyTasksColors.ink,
      secondaryContainer: isDark
          ? const Color(0xFF24433F)
          : const Color(0xFFDDF5F1),
      onSecondaryContainer: isDark
          ? const Color(0xFFE2F8F4)
          : MyTasksColors.ink,
      tertiary: MyTasksColors.butter,
      onTertiary: MyTasksColors.ink,
      tertiaryContainer: const Color(0xFFFFF4C2),
      onTertiaryContainer: MyTasksColors.ink,
      error: isDark ? const Color(0xFFFFB4AB) : MyTasksColors.overdue,
      onError: isDark ? const Color(0xFF690005) : MyTasksColors.white,
      errorContainer: isDark
          ? const Color(0xFF93000A)
          : const Color(0xFFFFDAD6),
      onErrorContainer: isDark
          ? const Color(0xFFFFDAD6)
          : const Color(0xFF410002),
      surface: surface,
      onSurface: ink,
      surfaceContainerHighest: isDark
          ? const Color(0xFF33352F)
          : MyTasksColors.surfaceMuted,
      onSurfaceVariant: muted,
      outline: isDark ? const Color(0xFF938D82) : const Color(0xFF827A6E),
      outlineVariant: border,
      shadow: Colors.black,
      scrim: Colors.black54,
      inverseSurface: isDark ? const Color(0xFFE9E1D5) : MyTasksColors.ink,
      onInverseSurface: isDark ? MyTasksColors.ink : MyTasksColors.cream,
      inversePrimary: isDark ? MyTasksColors.coralInk : const Color(0xFFFFAAA3),
      surfaceTint: primary,
    );

    final textTheme = _textTheme(ink, muted);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(28),
      side: BorderSide(color: border),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      fontFamily: 'NunitoSans',
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: textTheme.headlineMedium,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 1,
        shadowColor: isDark
            ? Colors.black.withValues(alpha: 0.24)
            : const Color(0xFF72584A).withValues(alpha: 0.07),
        shape: shape,
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: MyTasksColors.ink,
          disabledBackgroundColor: border,
          disabledForegroundColor: muted,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          minimumSize: const Size(44, 44),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          side: BorderSide(color: border),
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(color: muted),
        hintStyle: textTheme.bodyMedium?.copyWith(color: muted),
        helperStyle: textTheme.bodySmall?.copyWith(color: muted),
        errorStyle: textTheme.bodySmall?.copyWith(
          color: colorScheme.error,
          fontWeight: FontWeight.w800,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: MyTasksColors.tealInk, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: MyTasksColors.ink,
        shape: const CircleBorder(),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? const Color(0xFF343630) : MyTasksColors.ink,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: MyTasksColors.cream,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: MyTasksColors.tealInk,
        linearTrackColor: border,
      ),
      iconTheme: IconThemeData(color: MyTasksColors.tealInk),
    );
  }

  static TextTheme _textTheme(Color ink, Color muted) => TextTheme(
    displayLarge: TextStyle(
      color: ink,
      fontSize: 56,
      height: 1,
      letterSpacing: -2.2,
      fontWeight: FontWeight.w900,
    ),
    displayMedium: TextStyle(
      color: ink,
      fontSize: 36,
      height: 1.1,
      letterSpacing: -0.8,
      fontWeight: FontWeight.w900,
    ),
    headlineLarge: TextStyle(
      color: ink,
      fontSize: 28,
      height: 1.15,
      letterSpacing: -0.4,
      fontWeight: FontWeight.w900,
    ),
    headlineMedium: TextStyle(
      color: ink,
      fontSize: 22,
      height: 1.2,
      letterSpacing: -0.2,
      fontWeight: FontWeight.w900,
    ),
    headlineSmall: TextStyle(
      color: ink,
      fontSize: 18,
      height: 1.25,
      fontWeight: FontWeight.w800,
    ),
    titleLarge: TextStyle(
      color: ink,
      fontSize: 18,
      height: 1.25,
      fontWeight: FontWeight.w900,
    ),
    titleMedium: TextStyle(
      color: ink,
      fontSize: 16,
      height: 1.3,
      fontWeight: FontWeight.w800,
    ),
    titleSmall: TextStyle(
      color: ink,
      fontSize: 14,
      height: 1.3,
      fontWeight: FontWeight.w800,
    ),
    bodyLarge: TextStyle(
      color: ink,
      fontSize: 16,
      height: 1.45,
      fontWeight: FontWeight.w700,
    ),
    bodyMedium: TextStyle(
      color: ink,
      fontSize: 14,
      height: 1.45,
      fontWeight: FontWeight.w700,
    ),
    bodySmall: TextStyle(
      color: muted,
      fontSize: 12,
      height: 1.4,
      fontWeight: FontWeight.w700,
    ),
    labelLarge: TextStyle(
      color: ink,
      fontSize: 14,
      height: 1.2,
      fontWeight: FontWeight.w800,
    ),
    labelMedium: TextStyle(
      color: ink,
      fontSize: 13,
      height: 1.2,
      fontWeight: FontWeight.w800,
    ),
    labelSmall: TextStyle(
      color: muted,
      fontSize: 11,
      height: 1.25,
      fontWeight: FontWeight.w700,
    ),
  );
}
