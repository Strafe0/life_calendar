import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static get light => ThemeData(
        brightness: Brightness.light,
        colorScheme: colorSchemeLight,
        fontFamily: 'Roboto',
        textTheme: textLight,
        appBarTheme: appBarLight,
        floatingActionButtonTheme: floatingActionButtonLight,
        iconTheme: iconLight,
        elevatedButtonTheme: elevatedButtonLight,
        inputDecorationTheme: inputDecorationLight,
        cardTheme: cardLight,
        dialogTheme: dialogLight,
        popupMenuTheme: popupMenuLight,
      );

  static get dark => ThemeData(
        brightness: Brightness.dark,
        colorScheme: colorSchemeDark,
        fontFamily: 'Roboto',
        textTheme: textDark,
        appBarTheme: appBarDark,
        floatingActionButtonTheme: floatingActionButtonDark,
        iconTheme: iconDark,
        elevatedButtonTheme: elevatedButtonDark,
        inputDecorationTheme: inputDecorationDark,
        cardTheme: cardDark,
        dialogTheme: dialogDark,
        popupMenuTheme: popupMenuDark,
      );

  static get goodWeekColor => const Color(0xFF18C248);

  static get badWeekColor => const Color(0xFFFC0F00);

  static get neutralWeekColor => const Color(0xFF606060);

  static get futureWeekColor => const Color(0xFFb0bec5);

  static get currentWeekColor => const Color(0xFF2196f3);

  // ===========================================================================
  // Light themes
  // ===========================================================================

  static get colorSchemeLight => const ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF0151DF),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFDBE1FF),
    onPrimaryContainer: Color(0xFF00174D),
    secondary: Color(0xFF595E72),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFDDE1F9),
    onSecondaryContainer: Color(0xFF161B2C),
    tertiary: Color(0xFF745470),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFFFD6F7),
    onTertiaryContainer: Color(0xFF2B122A),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    surface: Color(0xFFFBF8FD),
    onSurface: Color(0xFF1B1B1F),
    onSurfaceVariant: Color(0xFF45464F),
    outline: Color(0xFF767680),
  );

  static get textLight => const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w400,
      height: 1.25,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w400,
      height: 1.29,
    ),
    headlineSmall: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w400,
      height: 1.45,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w400,
      height: 1.2,
      letterSpacing: 0.5,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.43,
      letterSpacing: 0.1,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.43,
      letterSpacing: 0.1,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.33,
      letterSpacing: 0.5,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      height: 1.45,
      letterSpacing: 0.5,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
      letterSpacing: 0.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.43,
      letterSpacing: 0.5,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.33,
      letterSpacing: 0.4,
    ),
  );

  static get appBarLight => const AppBarTheme(
    titleTextStyle: TextStyle(
      color: Color(0xFFC7C6CA),
      fontSize: 20,
      fontWeight: FontWeight.w400,
      height: 1.2,
      letterSpacing: 0.5,
    ), //titleLarge
    backgroundColor: Color(0xFF303034), //primary
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Color(0xFF1B1B1F),
    ),
    iconTheme: IconThemeData(color: Color(0xFFC7C6CA)),
  );

  static get floatingActionButtonLight => const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF0151DF), // primary
    foregroundColor: Color(0xFFFFFFFF), // onPrimary
  );

  static get iconLight => const IconThemeData(
    color: Color(0xFFFFFFFF),
  );

  static get elevatedButtonLight => ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: const WidgetStatePropertyAll(Color(0xFF0151DF)),
      foregroundColor: const WidgetStatePropertyAll(Color(0xFFFFFFFF)),
      textStyle: const WidgetStatePropertyAll(
        TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.43,
          letterSpacing: 0.1,
        ),
      ),
      elevation: WidgetStateProperty.resolveWith((states) {
        const Set<WidgetState> interactiveStates = <WidgetState>{
          WidgetState.pressed,
          WidgetState.hovered,
          WidgetState.focused,
        };
        if (states.any(interactiveStates.contains)) {
          return 0;
        }
        return 8;
      }),
    ),
  );

  static get inputDecorationLight => const InputDecorationTheme(
    border: UnderlineInputBorder(
      borderSide: BorderSide(color: Color(0xFF1B1B1F)),
    ),
    hintStyle: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
      letterSpacing: 0.5,
    ),
  );

  static get cardLight => const CardTheme(
    color: Color(0xFFF2F0F4),
    surfaceTintColor: Colors.transparent,
    elevation: 1.0,
  );

  static get dialogLight => const DialogTheme(
    backgroundColor: Color(0xFFF2F0F4),
    surfaceTintColor: Colors.transparent,
  );

  static get popupMenuLight => const PopupMenuThemeData(
    color: Color(0xFFF2F0F4),
    surfaceTintColor: Colors.transparent,
    textStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.43,
      letterSpacing: 0.5,
    ),
  );

  // ===========================================================================
  // Dark themes
  // ===========================================================================

  static get colorSchemeDark => const ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFB5C4FF),
    onPrimary: Color(0xFF00297A),
    primaryContainer: Color(0xFF003CAB),
    onPrimaryContainer: Color(0xFFDBE1FF),
    secondary: Color(0xFFC1C5DD),
    onSecondary: Color(0xFF2B3042),
    secondaryContainer: Color(0xFF414659),
    onSecondaryContainer: Color(0xFFDDE1F9),
    tertiary: Color(0xFFE2BBDB),
    onTertiary: Color(0xFF422740),
    tertiaryContainer: Color(0xFF5B3D57),
    onTertiaryContainer: Color(0xFFFFD6F7),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF131316),
    onSurface: Color(0xFFC7C6CA),
    onSurfaceVariant: Color(0xFFC6C6D0),
    outline: Color(0xFF8F909A),
  );

  static get textDark => const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w400,
      height: 1.25,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w400,
      height: 1.29,
    ),
    headlineSmall: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w400,
      height: 1.45,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w400,
      height: 1.2,
      letterSpacing: 0.5,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.43,
      letterSpacing: 0.1,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.43,
      letterSpacing: 0.1,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.33,
      letterSpacing: 0.5,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      height: 1.45,
      letterSpacing: 0.5,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
      letterSpacing: 0.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.43,
      letterSpacing: 0.5,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.33,
      letterSpacing: 0.4,
    ),
  );

  static get appBarDark => const AppBarTheme(
    titleTextStyle: TextStyle(
      color: Color(0xFFC7C6CA),
      fontSize: 20,
      fontWeight: FontWeight.w400,
      height: 1.2,
      letterSpacing: 0.5,
    ), //titleLarge
    backgroundColor: Color(0xFF303034), //primary
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Color(0xFF1B1B1F),
    ),
    iconTheme: IconThemeData(color: Color(0xFFC7C6CA)),
  );

  static get floatingActionButtonDark => const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFFB5C4FF), // primary
    foregroundColor: Color(0xFF00297A), // onPrimary
  );

  static get iconDark => const IconThemeData(
    color: Color(0xFFC7C6CA),
  );

  static get elevatedButtonDark => ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: const WidgetStatePropertyAll(Color(0xFFB5C4FF)),
      foregroundColor: const WidgetStatePropertyAll(Color(0xFF00297A)),
      textStyle: const WidgetStatePropertyAll(
        TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.43,
          letterSpacing: 0.1,
        ),
      ),
      elevation: WidgetStateProperty.resolveWith((states) {
        const Set<WidgetState> interactiveStates = <WidgetState>{
          WidgetState.pressed,
          WidgetState.hovered,
          WidgetState.focused,
        };
        if (states.any(interactiveStates.contains)) {
          return 0;
        }
        return 8;
      }),
    ),
  );

  static get inputDecorationDark => const InputDecorationTheme(
    border: UnderlineInputBorder(
      borderSide: BorderSide(color: Color(0xFFE4E2E6)),
    ),
    hintStyle: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
      letterSpacing: 0.5,
    ),
  );

  static get cardDark => const CardTheme(
    color: Color(0xFF303034),
    surfaceTintColor: Colors.transparent,
    elevation: 2.0,
  );

  static get dialogDark => const DialogTheme(
    backgroundColor: Color(0xFF303034),
    surfaceTintColor: Colors.transparent,
  );

  static get popupMenuDark => const PopupMenuThemeData(
    color: Color(0xFF303034),
    surfaceTintColor: Colors.transparent,
    textStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.43,
      letterSpacing: 0.5,
    ),
  );
}
