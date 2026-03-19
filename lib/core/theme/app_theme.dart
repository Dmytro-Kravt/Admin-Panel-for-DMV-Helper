import 'package:flutter/material.dart';

class AppTheme {

  static final ThemeData lightMode = ThemeData(
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      filled: true,
      fillColor: Color(0XFFF0F0F0),
      contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
      enabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        borderSide: const BorderSide(color: Colors.grey, width: 1.0)
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        borderSide: const BorderSide(color: Colors.greenAccent, width: 2.0)
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        borderSide: const BorderSide(color: Colors.red, width: 2.0)
      ),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
          borderSide: const BorderSide(color: Colors.red, width: 2.0)
      ),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 20.0,
        fontWeight: .bold
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: .normal
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        color: Colors.grey
      ),
      bodyLarge: TextStyle(
          fontSize: 14,
          fontWeight: .normal,
          color: Colors.greenAccent
      ),
    ),
    colorScheme: ColorScheme.light(
      surface: Color(0XFFE1E1E1),
      secondary: Color(0XFFEEEEEE),
      primaryContainer: Color(0XFFD1D5DA),
      onSecondaryContainer: Colors.greenAccent,
        onTertiary: Color(0XFFD7D7D7)
    ),
    navigationRailTheme: NavigationRailThemeData(

        backgroundColor: Color(0XFFC5C5C5)
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.greenAccent,
        foregroundColor: Colors.black,
        minimumSize: const Size(330, 45),
      )
    )
  );


  static final ThemeData darkMode = ThemeData(
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      filled: true,
      fillColor: Color(0XFFF0F0F0),
      contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
      enabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        borderSide: const BorderSide(color: Color(0XFF3E3E3E), width: 1.0)
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        borderSide: const BorderSide(color: Color(0XFF9400D3), width: 2.0)
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        borderSide: const BorderSide(color: Colors.red, width: 2.0)
      ),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
          borderSide: const BorderSide(color: Colors.red, width: 2.0)
      ),
    ),
    textTheme: const TextTheme(
        titleLarge: TextStyle(
            fontSize: 20.0,
            fontWeight: .bold
        ),
        bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: .normal
        ),
        labelSmall: TextStyle(
            fontSize: 11,
            color: Colors.grey
        ),
        bodyLarge: TextStyle(
            fontSize: 14,
            fontWeight: .normal,
          color: Color(0XFF9400D3)
      ),
    ),
    colorScheme: ColorScheme.dark(
      surface: Color(0XFF737373),
      secondary: Color(0XFFC1C1C1),
      primaryContainer: Color(0XFF48525C),
      onSecondaryContainer: Color(0XFF9400D3),
      onTertiary: Color(0XFFD7D7D7)
    ),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: Color(0XFF4E4E4E)
    ),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(330, 45),
              backgroundColor: Color(0XFF9400D3),
            foregroundColor: Colors.white,
            disabledBackgroundColor: Color(0XFF737373),
          )
      )
  );
}