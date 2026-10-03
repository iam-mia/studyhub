import 'package:flutter/material.dart';

Color getColor(BuildContext context, String colorName) {
  return Theme.of(context).extension<AppColors>()?.colors[colorName] ??
      Colors.red;
}

Color lightenPastel(Color color, {double amount = 0.8}) {
  return Color.lerp(color, Colors.white, amount) ?? color;
}

Color darkenPastel(Color color, {double amount = 0.8}) {
  return Color.lerp(color, Colors.black, amount) ?? color;
}

class AppColors extends ThemeExtension<AppColors> {
  final Map<String, Color> colors;

  AppColors({required this.colors});

  @override
  ThemeExtension<AppColors> copyWith({Map<String, Color>? colors}) {
    return AppColors(colors: colors ?? this.colors);
  }

  @override
  ThemeExtension<AppColors> lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    Map<String, Color> newColors = {};
    colors.forEach((key, value) {
      newColors[key] = Color.lerp(value, other.colors[key], t) ?? value;
    });
    return AppColors(colors: newColors);
  }
}

AppColors getCashewThemeColors(Brightness brightness) {
  final bool isLight = brightness == Brightness.light;
  return AppColors(
    colors: {
      "white": isLight ? Colors.white : Colors.black,
      "black": isLight ? const Color(0xFF111827) : const Color(0xFFFFFFFF),
      // textLight: high contrast, clear readability in both modes
      "textLight":
          isLight ? const Color(0xFF4B5563) : const Color(0xFFCBD5E1),
      "canvasContainer":
          isLight ? const Color(0xFFF1F4F8) : const Color(0xFF0F1216),
      "lightDarkAccent":
          isLight ? const Color(0xFFFFFFFF) : const Color(0xFF1C2129),
      "lightDarkAccentHeavyLight":
          isLight ? const Color(0xFFF8FAFC) : const Color(0xFF262D38),
      "incomeAmount":
          isLight ? const Color(0xFF2E7D32) : const Color(0xFF4CAF50),
      "expenseAmount":
          isLight ? const Color(0xFFC62828) : const Color(0xFFEF5350),
      "warningOrange":
          isLight ? const Color(0xFFE65100) : const Color(0xFFFFA726),
      "starYellow": const Color(0xFFFFB300),
      "dividerColor":
          isLight ? const Color(0xFFE2E8F0) : const Color(0xFF2E3846),
      "primaryAccent":
          isLight ? const Color(0xFF3F51B5) : const Color(0xFF7986CB),
      // Document type colors
      "pdfColor": const Color(0xFFE53935),
      "wordColor": const Color(0xFF1E88E5),
      "pptColor": const Color(0xFFFB8C00),
      "linkColor": const Color(0xFF43A047),
    },
  );
}
