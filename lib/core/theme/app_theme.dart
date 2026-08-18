import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color primaryColor = Color(0xFF006B49);
  static const Color primaryDark = Color(0xFF0C2B24);
  static const Color coralColor = Color(0xFFD71920);
  static const Color goldColor = Color(0xFFB88A37);
  static const Color tealColor = Color(0xFF00843D);
  static const Color backgroundColor = Color(0xFFF6F7F3);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color surfaceMutedColor = Color(0xFFF0F5F1);
  static const Color sandColor = Color(0xFFF7EEDB);
  static const Color textColor = Color(0xFF171C19);
  static const Color secondaryTextColor = Color(0xFF5D6762);
  static const Color outlineColor = Color(0xFFDDE3DF);
  static const Color uaeRed = Color(0xFFFF0000);
  static const Color uaeGreen = Color(0xFF00843D);
  static const Color uaeWhiteAccent = Color(0xFFE9EEEB);
  static const Color uaeBlack = Color(0xFF101820);

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primaryColor, Color(0xFF0B9256)],
    stops: [0, 0.54, 1],
  );

  static const LinearGradient pageGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF8FAF6), Color(0xFFF4F7F2), Color(0xFFFBF5F3)],
    stops: [0, 0.58, 1],
  );

  static ThemeData get lightTheme {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
        ).copyWith(
          primary: primaryColor,
          onPrimary: Colors.white,
          secondary: coralColor,
          tertiary: goldColor,
          primaryContainer: const Color(0xFFDDEFE5),
          onPrimaryContainer: primaryDark,
          secondaryContainer: const Color(0xFFFCE3E4),
          onSecondaryContainer: const Color(0xFF641014),
          tertiaryContainer: const Color(0xFFF4E8CC),
          onTertiaryContainer: const Color(0xFF51390E),
          surface: surfaceColor,
          onSurface: textColor,
          onSurfaceVariant: secondaryTextColor,
          outline: const Color(0xFF8B8495),
          outlineVariant: outlineColor,
        );

    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundColor,
    );

    return baseTheme.copyWith(
      textTheme: baseTheme.textTheme.copyWith(
        displaySmall: const TextStyle(
          fontSize: 44,
          height: 1.08,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.4,
          color: textColor,
        ),
        headlineLarge: const TextStyle(
          fontSize: 36,
          height: 1.12,
          fontWeight: FontWeight.w700,
          letterSpacing: -1,
          color: textColor,
        ),
        headlineMedium: const TextStyle(
          fontSize: 30,
          height: 1.16,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.7,
          color: textColor,
        ),
        headlineSmall: const TextStyle(
          fontSize: 24,
          height: 1.2,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.35,
          color: textColor,
        ),
        titleLarge: const TextStyle(
          fontSize: 20,
          height: 1.3,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
        titleMedium: const TextStyle(
          fontSize: 16,
          height: 1.4,
          fontWeight: FontWeight.w600,
          color: secondaryTextColor,
        ),
        bodyLarge: const TextStyle(fontSize: 16, height: 1.5, color: textColor),
        bodyMedium: const TextStyle(
          fontSize: 14,
          height: 1.45,
          color: secondaryTextColor,
        ),
        labelLarge: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF8FAF6),
        foregroundColor: textColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: 68,
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: primaryDark.withValues(alpha: 0.1),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: outlineColor),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          side: const BorderSide(color: outlineColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: outlineColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: outlineColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: surfaceColor,
        surfaceTintColor: Colors.transparent,
        indicatorColor: colorScheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            color: states.contains(WidgetState.selected)
                ? primaryColor
                : secondaryTextColor,
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w600,
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: Colors.transparent,
        indicatorColor: colorScheme.primaryContainer,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        selectedIconTheme: const IconThemeData(color: primaryColor),
        selectedLabelTextStyle: const TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.w700,
        ),
        unselectedIconTheme: const IconThemeData(color: secondaryTextColor),
        unselectedLabelTextStyle: const TextStyle(
          color: secondaryTextColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceColor,
        selectedColor: colorScheme.primaryContainer,
        side: const BorderSide(color: outlineColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        labelStyle: const TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      ),
      dividerTheme: const DividerThemeData(
        color: outlineColor,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: textColor,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: primaryColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? primaryColor
              : Colors.transparent,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: surfaceMutedColor,
        circularTrackColor: surfaceMutedColor,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceColor,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
      ),
    );
  }
}
