import 'package:flutter/material.dart';

TextTheme getDenseTextTheme(TextTheme base, {double delta = 2.0}) {
  // Helper to subtract delta if fontSize is non-null.
  TextStyle subtractDelta(TextStyle style) {
    return style.copyWith(fontSize: (style.fontSize ?? 14.0) - delta);
  }

  return base.copyWith(
    displayLarge: subtractDelta(base.displayLarge!),
    displayMedium: subtractDelta(base.displayMedium!),
    displaySmall: subtractDelta(base.displaySmall!),
    headlineLarge: subtractDelta(base.headlineLarge!),
    headlineMedium: subtractDelta(base.headlineMedium!),
    headlineSmall: subtractDelta(base.headlineSmall!),
    titleLarge: subtractDelta(base.titleLarge!),
    titleMedium: subtractDelta(base.titleMedium!),
    titleSmall: subtractDelta(base.titleSmall!),
    bodyLarge: subtractDelta(base.bodyLarge!),
    bodyMedium: subtractDelta(base.bodyMedium!),
    bodySmall: subtractDelta(base.bodySmall!),
    labelLarge: subtractDelta(base.labelLarge!),
    labelSmall: subtractDelta(base.labelSmall!),
  );
}
