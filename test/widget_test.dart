import 'package:flutter_test/flutter_test.dart';
import 'package:studyhub/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('StudyHub Theme System initializes properly',
      (WidgetTester tester) async {
    final lightColors = getCashewThemeColors(Brightness.light);
    final darkColors = getCashewThemeColors(Brightness.dark);

    expect(lightColors.colors['canvasContainer'], isNotNull);
    expect(darkColors.colors['canvasContainer'], isNotNull);
    expect(lightColors.colors['starYellow'], equals(const Color(0xFFFFB300)));
  });
}
