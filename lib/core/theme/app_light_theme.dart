import 'package:flutter/material.dart';

final ThemeData appLightThemeData = ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.redAccent, brightness: Brightness.light))
    .copyWith(
  useMaterial3: true,
);
