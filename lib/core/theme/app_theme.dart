import 'package:flutter/material.dart';
import 'app_colors.dart';

ThemeData getAppTheme(Brightness brightness) {
  final isLight = brightness == Brightness.light;
  final appColors = getCashewThemeColors(brightness);
  final canvasColor = appColors.colors["canvasContainer"]!;
  final cardColor = appColors.colors["lightDarkAccent"]!;
  final textColor = appColors.colors["black"]!;
  final textLight = appColors.colors["textLight"]!;
  final dividerCol = appColors.colors["dividerColor"]!;
  final primaryAccent = appColors.colors["primaryAccent"]!;

  final colorScheme = ColorScheme.fromSeed(
    seedColor: primaryAccent,
    brightness: brightness,
    surface: cardColor,
    onSurface: textColor,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: canvasColor,
    canvasColor: canvasColor,
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: isLight ? 0.5 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: dividerCol, width: 1.2),
      ),
      margin: EdgeInsets.zero,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: cardColor,
      labelStyle: TextStyle(
        color: textColor,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      side: BorderSide(color: dividerCol),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: cardColor,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      elevation: 6,
      showDragHandle: false,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: cardColor,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: dividerCol),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: canvasColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: textColor,
      ),
      iconTheme: IconThemeData(color: textColor),
    ),
    dividerTheme: DividerThemeData(
      color: dividerCol,
      thickness: 1,
      space: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isLight ? const Color(0xFFF8FAFC) : const Color(0xFF222934),
      labelStyle: TextStyle(color: textLight, fontSize: 14),
      hintStyle: TextStyle(color: textLight.withValues(alpha: 0.8), fontSize: 14),
      prefixIconColor: textLight,
      suffixIconColor: textLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: dividerCol),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: dividerCol, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: primaryAccent, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    extensions: [appColors],
  );
}
