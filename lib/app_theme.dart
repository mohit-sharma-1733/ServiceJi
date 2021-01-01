import 'package:flutter/material.dart';
import 'package:ServiceJi/utils/colors.dart';
import 'package:ServiceJi/main.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: backgroundColor,
    highlightColor: Color(0xFFF6F6F6),
    primaryColor: primaryColor,
    primaryColorDark: colorPrimaryDark,
    accentColor: colorAccent,
    errorColor: Colors.red,
    hoverColor: Colors.grey,
    fontFamily: 'Jost',
    appBarTheme: AppBarTheme(
      color: app_Background,
      iconTheme: IconThemeData(
        color: textPrimaryColour,
      ),
    ),

    colorScheme: ColorScheme.light(
      primary: primaryColor,
      onPrimary: colorAccent,
      surface: Colors.white,
      primaryVariant: primaryColor,
      secondary: colorAccent,
      onSecondary: primaryColor,
    ),
    cardTheme: CardTheme(
      color: Colors.white,
    ),
    iconTheme: IconThemeData(
      color: textPrimaryColour,
    ),
    textTheme: TextTheme(
      button: TextStyle(color: colorAccent),
      headline6: TextStyle(
        color: colorAccent,
      ),
      headline5: TextStyle(
        color: textPrimaryColour,
      ),
      headline4: TextStyle(
        color: Color(0xFFF5F4F4),
      ),
      subtitle1: TextStyle(
        color: textSecondaryColour,
      ),
      subtitle2: TextStyle(
        color: textPrimaryColour,
      ),
      headline3: TextStyle(
        color: primaryColor,
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: Color(0xFF131d25),
    highlightColor: Color(0xFF131d25),
    errorColor: Color(0xFFCF6676),
    appBarTheme: AppBarTheme(
      color: Color(0xFF131d25),
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
    ),
    cardColor: Color(0xFF49516e),
    primaryColor: Color(0xFF131d25),
    accentColor: white_color,
    primaryColorDark: Color(0xFF131d25),
    hoverColor: Colors.black,
    fontFamily: 'Jost',
    colorScheme: ColorScheme.light(
        primary: Color(0xFF131d25), onPrimary: Color(0xFF1D2939), surface: Color(0xFF1D2939), primaryVariant: Color(0xFF131d25), secondary: Colors.pinkAccent, onSecondary: Colors.white),
    cardTheme: CardTheme(
      color: Color(0xFF1D2939),
    ),
    iconTheme: IconThemeData(
      color: Colors.white70,
    ),
    textTheme: TextTheme(
      button: TextStyle(color: Colors.white),
      headline6: TextStyle(
        color: Colors.white70,
      ),
      headline5: TextStyle(
        color: Colors.white54,
      ),
      headline4: TextStyle(
        color: Color(0xFF1D2939),
      ),
      subtitle1: TextStyle(
        color: Colors.white70,
      ),
      subtitle2: TextStyle(
        color: Colors.white54,
      ),
      headline3: TextStyle(
        color: Color(0xFF131d25),
      ),
    ),
  );
}
