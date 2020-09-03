import 'package:flutter/material.dart';

ThemeData lightTheme() {
  return theme(
    isDark: false,
    indicatorColor: Colors.black,
    appBarColor: Colors.white,
    backgroundColor: Colors.grey[200],
    cardColor: Colors.grey[50],
    secondaryIndicatorColor: Colors.green,
  );
}

ThemeData darkTheme() {
  return theme(
    isDark: true,
    indicatorColor: Colors.orange,
    appBarColor: Colors.grey[900],
    backgroundColor: Colors.grey[850],
    cardColor: Colors.grey[800],
    secondaryIndicatorColor: Colors.green,
  );
}

ThemeData theme({
  bool isDark,
  Color indicatorColor,
  Color appBarColor,
  Color backgroundColor,
  Color cardColor,
  Color secondaryIndicatorColor,
}) {
  return ThemeData(
    brightness: isDark ? Brightness.dark : Brightness.light,
    // Indicator color.
    indicatorColor: indicatorColor,
    accentColor: indicatorColor,
    toggleableActiveColor: indicatorColor,
    cursorColor: indicatorColor,
    buttonColor: indicatorColor,
    textSelectionHandleColor: indicatorColor,
    // Secondary indicator color.
    textSelectionColor: secondaryIndicatorColor,
    tabBarTheme: TabBarTheme(
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(
          color: isDark ? indicatorColor : indicatorColor,
          width: 2,
        ),
      ),
    ),
    // App color.
    primaryColor: isDark ? appBarColor : Colors.orange,
    // Background color.
    backgroundColor: backgroundColor,
    scaffoldBackgroundColor: backgroundColor,
    canvasColor: backgroundColor,
    // Card color.
    dialogBackgroundColor: cardColor,
    cardColor: cardColor,
  );
}
