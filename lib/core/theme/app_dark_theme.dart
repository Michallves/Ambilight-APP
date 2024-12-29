import 'package:flutter/material.dart';

final ThemeData appDarkThemeData = ThemeData.from(
  colorScheme: ColorScheme.fromSeed(
    // Use uma cor que combine com o seu app ou que lembre
    // o "accent color" do Windows (por ex., #0078D4 para azul).
    // Aqui escolhi um azul sutil só de exemplo.
    seedColor: Colors.redAccent,
    brightness: Brightness.dark,
  ),
).copyWith(
  useMaterial3: true,

  // Cor de fundo principal, um cinza bem escuro
  scaffoldBackgroundColor: const Color(0xFF202020),
);
