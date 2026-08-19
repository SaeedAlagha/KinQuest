import 'package:flutter/material.dart';

import 'appearance_controller.dart';

enum SilaVisualStyle {
  classic,
  familyYear,
  space,
  khalifaUniversity,
  desertNights,
  pearlLagoon,
}

@immutable
class SilaThemeTokens extends ThemeExtension<SilaThemeTokens> {
  const SilaThemeTokens({
    required this.pageGradient,
    required this.heroGradient,
    required this.visualStyle,
  });

  final LinearGradient pageGradient;
  final LinearGradient heroGradient;
  final SilaVisualStyle visualStyle;

  bool get isFamilyYear => visualStyle == SilaVisualStyle.familyYear;

  @override
  SilaThemeTokens copyWith({
    LinearGradient? pageGradient,
    LinearGradient? heroGradient,
    SilaVisualStyle? visualStyle,
  }) {
    return SilaThemeTokens(
      pageGradient: pageGradient ?? this.pageGradient,
      heroGradient: heroGradient ?? this.heroGradient,
      visualStyle: visualStyle ?? this.visualStyle,
    );
  }

  @override
  SilaThemeTokens lerp(SilaThemeTokens? other, double t) {
    if (other == null) {
      return this;
    }

    return SilaThemeTokens(
      pageGradient: LinearGradient.lerp(pageGradient, other.pageGradient, t)!,
      heroGradient: LinearGradient.lerp(heroGradient, other.heroGradient, t)!,
      visualStyle: t < 0.5 ? visualStyle : other.visualStyle,
    );
  }
}

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

  static const LinearGradient _darkPageGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF08130F), Color(0xFF0D1B16), Color(0xFF181313)],
    stops: [0, 0.58, 1],
  );

  static const LinearGradient _familyYearPageGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFF4DC), Color(0xFFF2E2C0), Color(0xFFF8D9D3)],
    stops: [0, 0.58, 1],
  );

  static const LinearGradient _spacePageGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF040615), Color(0xFF10133B), Color(0xFF191044)],
    stops: [0, 0.58, 1],
  );

  static const LinearGradient _kuPageGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF5FAFF), Color(0xFFE6F3FC), Color(0xFFF0F7FB)],
    stops: [0, 0.55, 1],
  );

  static const LinearGradient _desertNightsPageGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF120D24), Color(0xFF2B1633), Color(0xFF40202F)],
    stops: [0, 0.56, 1],
  );

  static const LinearGradient _pearlLagoonPageGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF9F6EF), Color(0xFFE3F4F1), Color(0xFFE9F4FA)],
    stops: [0, 0.52, 1],
  );

  static LinearGradient pageGradientFor(BuildContext context) {
    return Theme.of(context).extension<SilaThemeTokens>()?.pageGradient ??
        pageGradient;
  }

  static LinearGradient heroGradientFor(BuildContext context) {
    return Theme.of(context).extension<SilaThemeTokens>()?.heroGradient ??
        brandGradient;
  }

  static ThemeData forAppearance(AppAppearance appearance) {
    return switch (appearance) {
      AppAppearance.light => lightTheme,
      AppAppearance.dark => darkTheme,
      AppAppearance.familyYear2026 => familyYearTheme,
      AppAppearance.space => spaceTheme,
      AppAppearance.khalifaUniversity => khalifaUniversityTheme,
      AppAppearance.desertNights => desertNightsTheme,
      AppAppearance.pearlLagoon => pearlLagoonTheme,
    };
  }

  static ThemeData get lightTheme => _buildTheme(
    brightness: Brightness.light,
    primary: primaryColor,
    secondary: coralColor,
    background: backgroundColor,
    surface: surfaceColor,
    surfaceMuted: surfaceMutedColor,
    text: textColor,
    secondaryText: secondaryTextColor,
    outline: outlineColor,
    appBar: const Color(0xFFF8FAF6),
    pageGradient: pageGradient,
    heroGradient: brandGradient,
  );

  static ThemeData get darkTheme => _buildTheme(
    brightness: Brightness.dark,
    primary: const Color(0xFF45C98D),
    secondary: const Color(0xFFFF6F73),
    background: const Color(0xFF09140F),
    surface: const Color(0xFF13221C),
    surfaceMuted: const Color(0xFF1B3028),
    text: const Color(0xFFF1F7F3),
    secondaryText: const Color(0xFFB6C8BF),
    outline: const Color(0xFF344C41),
    appBar: const Color(0xFF0A1712),
    pageGradient: _darkPageGradient,
    heroGradient: const LinearGradient(
      colors: [Color(0xFF12382C), Color(0xFF006B49), Color(0xFF51232D)],
    ),
  );

  static ThemeData get familyYearTheme => _buildTheme(
    brightness: Brightness.light,
    primary: const Color(0xFF7A2432),
    secondary: uaeGreen,
    tertiary: const Color(0xFFC3943E),
    background: const Color(0xFFF4E3C4),
    surface: const Color(0xFFFFF9EA),
    surfaceMuted: const Color(0xFFEAD4A9),
    text: const Color(0xFF2E211C),
    secondaryText: const Color(0xFF705D50),
    outline: const Color(0xFFD5BA86),
    appBar: const Color(0xFFFFF3D8),
    pageGradient: _familyYearPageGradient,
    heroGradient: const LinearGradient(
      begin: AlignmentDirectional.topStart,
      end: AlignmentDirectional.bottomEnd,
      colors: [Color(0xFF6E1F2C), Color(0xFF9A3542), Color(0xFF006B49)],
    ),
    visualStyle: SilaVisualStyle.familyYear,
    primaryContainer: const Color(0xFFF4D4D1),
    onPrimaryContainer: const Color(0xFF4F111D),
    secondaryContainer: const Color(0xFFD7ECDF),
    onSecondaryContainer: const Color(0xFF003D2A),
    cardRadius: 28,
    buttonRadius: 22,
  );

  static ThemeData get spaceTheme => _buildTheme(
    brightness: Brightness.dark,
    primary: const Color(0xFF69D8FF),
    secondary: const Color(0xFFAE8BFF),
    tertiary: const Color(0xFFFFC857),
    background: const Color(0xFF050716),
    surface: const Color(0xFF11172D),
    surfaceMuted: const Color(0xFF1B2340),
    text: const Color(0xFFF3F5FF),
    secondaryText: const Color(0xFFB9C1DE),
    outline: const Color(0xFF34416C),
    appBar: const Color(0xFF070A1D),
    pageGradient: _spacePageGradient,
    heroGradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF142B60), Color(0xFF44308C), Color(0xFF8B3FA8)],
    ),
    visualStyle: SilaVisualStyle.space,
    primaryContainer: const Color(0xFF173C58),
    onPrimaryContainer: const Color(0xFFCCF2FF),
    secondaryContainer: const Color(0xFF392C65),
    onSecondaryContainer: const Color(0xFFEADDFF),
    cardRadius: 22,
    buttonRadius: 20,
  );

  static ThemeData get khalifaUniversityTheme => _buildTheme(
    brightness: Brightness.light,
    primary: const Color(0xFF0057B8),
    secondary: const Color(0xFF00A9CE),
    tertiary: const Color(0xFF6F5091),
    background: const Color(0xFFEFF6FC),
    surface: Colors.white,
    surfaceMuted: const Color(0xFFDCECF7),
    text: const Color(0xFF10263B),
    secondaryText: const Color(0xFF526B7E),
    outline: const Color(0xFFC4D9E9),
    appBar: const Color(0xFFF5FAFF),
    pageGradient: _kuPageGradient,
    heroGradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF003C80), Color(0xFF0057B8), Color(0xFF00A9CE)],
    ),
    visualStyle: SilaVisualStyle.khalifaUniversity,
    primaryContainer: const Color(0xFFD7E9FA),
    onPrimaryContainer: const Color(0xFF002F64),
    secondaryContainer: const Color(0xFFD3F3FA),
    onSecondaryContainer: const Color(0xFF004E60),
    cardRadius: 18,
    buttonRadius: 12,
  );

  static ThemeData get desertNightsTheme => _buildTheme(
    brightness: Brightness.dark,
    primary: const Color(0xFFE8BD68),
    secondary: const Color(0xFFE17B69),
    tertiary: const Color(0xFFA98BE0),
    background: const Color(0xFF120D24),
    surface: const Color(0xFF25182E),
    surfaceMuted: const Color(0xFF38233C),
    text: const Color(0xFFFFF5E5),
    secondaryText: const Color(0xFFD8C5C5),
    outline: const Color(0xFF5A3B55),
    appBar: const Color(0xFF160F27),
    pageGradient: _desertNightsPageGradient,
    heroGradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF4A2144), Color(0xFF793C4A), Color(0xFFB36B50)],
    ),
    visualStyle: SilaVisualStyle.desertNights,
    primaryContainer: const Color(0xFF554421),
    onPrimaryContainer: const Color(0xFFFFE6AA),
    secondaryContainer: const Color(0xFF65332F),
    onSecondaryContainer: const Color(0xFFFFDAD3),
    cardRadius: 30,
    buttonRadius: 26,
  );

  static ThemeData get pearlLagoonTheme => _buildTheme(
    brightness: Brightness.light,
    primary: const Color(0xFF087F8C),
    secondary: const Color(0xFFE66E79),
    tertiary: const Color(0xFF8A72B5),
    background: const Color(0xFFEDF8F6),
    surface: const Color(0xFFFFFCF8),
    surfaceMuted: const Color(0xFFDDF1ED),
    text: const Color(0xFF173A3C),
    secondaryText: const Color(0xFF587374),
    outline: const Color(0xFFBFDCD8),
    appBar: const Color(0xFFF7FBF9),
    pageGradient: _pearlLagoonPageGradient,
    heroGradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF087F8C), Color(0xFF45B9B0), Color(0xFFE68B91)],
    ),
    visualStyle: SilaVisualStyle.pearlLagoon,
    primaryContainer: const Color(0xFFD1EFEC),
    onPrimaryContainer: const Color(0xFF004D54),
    secondaryContainer: const Color(0xFFFFDFE1),
    onSecondaryContainer: const Color(0xFF6C2029),
    cardRadius: 32,
    buttonRadius: 24,
  );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color primary,
    required Color secondary,
    Color tertiary = goldColor,
    required Color background,
    required Color surface,
    required Color surfaceMuted,
    required Color text,
    required Color secondaryText,
    required Color outline,
    required Color appBar,
    required LinearGradient pageGradient,
    required LinearGradient heroGradient,
    SilaVisualStyle visualStyle = SilaVisualStyle.classic,
    Color? primaryContainer,
    Color? onPrimaryContainer,
    Color? secondaryContainer,
    Color? onSecondaryContainer,
    double cardRadius = 24,
    double buttonRadius = 18,
  }) {
    final isDark = brightness == Brightness.dark;
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: primary,
          brightness: brightness,
        ).copyWith(
          primary: primary,
          onPrimary: isDark ? const Color(0xFF052017) : Colors.white,
          secondary: secondary,
          tertiary: tertiary,
          primaryContainer:
              primaryContainer ??
              (isDark ? const Color(0xFF164D36) : const Color(0xFFDDEFE5)),
          onPrimaryContainer:
              onPrimaryContainer ??
              (isDark ? const Color(0xFFD9F7E7) : primaryDark),
          secondaryContainer:
              secondaryContainer ??
              (isDark ? const Color(0xFF5B2226) : const Color(0xFFFCE3E4)),
          onSecondaryContainer:
              onSecondaryContainer ??
              (isDark ? const Color(0xFFFFDADD) : const Color(0xFF641014)),
          tertiaryContainer: isDark
              ? const Color(0xFF4B3A19)
              : const Color(0xFFF4E8CC),
          onTertiaryContainer: isDark
              ? const Color(0xFFFFE9B5)
              : const Color(0xFF51390E),
          surface: surface,
          onSurface: text,
          onSurfaceVariant: secondaryText,
          outline: isDark ? const Color(0xFF81978C) : const Color(0xFF8B8495),
          outlineVariant: outline,
        );

    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      fontFamily: 'NotoSansArabic',
      scaffoldBackgroundColor: background,
      extensions: [
        SilaThemeTokens(
          pageGradient: pageGradient,
          heroGradient: heroGradient,
          visualStyle: visualStyle,
        ),
      ],
    );

    return baseTheme.copyWith(
      textTheme: baseTheme.textTheme
          .copyWith(
            displaySmall: TextStyle(
              fontSize: 44,
              height: 1.08,
              fontWeight: FontWeight.w700,
              letterSpacing: -1.4,
              color: text,
            ),
            headlineLarge: TextStyle(
              fontSize: 36,
              height: 1.12,
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
              color: text,
            ),
            headlineMedium: TextStyle(
              fontSize: 30,
              height: 1.16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.7,
              color: text,
            ),
            headlineSmall: TextStyle(
              fontSize: 24,
              height: 1.2,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.35,
              color: text,
            ),
            titleLarge: TextStyle(
              fontSize: 20,
              height: 1.3,
              fontWeight: FontWeight.w700,
              color: text,
            ),
            titleMedium: TextStyle(
              fontSize: 16,
              height: 1.4,
              fontWeight: FontWeight.w600,
              color: secondaryText,
            ),
            bodyLarge: TextStyle(fontSize: 16, height: 1.5, color: text),
            bodyMedium: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: secondaryText,
            ),
            labelLarge: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
            ),
          )
          .apply(fontFamily: 'NotoSansArabic'),
      appBarTheme: AppBarTheme(
        backgroundColor: appBar,
        foregroundColor: text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: 68,
        titleTextStyle: TextStyle(
          color: text,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: primaryDark.withValues(alpha: isDark ? 0.34 : 0.1),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: BorderSide(color: outline),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: isDark ? const Color(0xFF052017) : Colors.white,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          side: BorderSide(color: outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary, width: 2),
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
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: colorScheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            color: states.contains(WidgetState.selected)
                ? primary
                : secondaryText,
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
        selectedIconTheme: IconThemeData(color: primary),
        selectedLabelTextStyle: TextStyle(
          color: primary,
          fontWeight: FontWeight.w700,
        ),
        unselectedIconTheme: IconThemeData(color: secondaryText),
        unselectedLabelTextStyle: TextStyle(
          color: secondaryText,
          fontWeight: FontWeight.w600,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: colorScheme.primaryContainer,
        side: BorderSide(color: outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        labelStyle: TextStyle(color: text, fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      ),
      dividerTheme: DividerThemeData(color: outline, thickness: 1, space: 1),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? const Color(0xFFE5F4EC) : text,
        contentTextStyle: TextStyle(
          color: isDark ? const Color(0xFF0A1712) : Colors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: isDark ? const Color(0xFF052017) : Colors.white,
        elevation: 1,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: primary,
        textColor: text,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? primary
              : Colors.transparent,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colorScheme.onPrimary
              : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? primary : null,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: surfaceMuted,
        circularTrackColor: surfaceMuted,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
      ),
    );
  }
}
