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

  // Você pode ajustar a cor do AppBar para algo parecido
  // com o Windows 11 dark. Por exemplo, #2B2B2B.
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF2B2B2B),
    elevation: 0,
    centerTitle: false,
    // Se quiser título à esquerda, false; se preferir centralizado, true
  ),

  // Exemplo de cor de texto e icones no AppBar
  iconTheme: const IconThemeData(color: Colors.white),
  textTheme: const TextTheme(
    titleLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white70),
  ),

  // Ajustes de InputDecoration também podem seguir esse padrão dark.
  inputDecorationTheme: InputDecorationTheme(
    contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
    fillColor: const Color(0xFF2C2C2C), // Fundo levemente diferente
    filled: true,
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.white54),
      borderRadius: BorderRadius.circular(16),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    labelStyle: const TextStyle(color: Colors.white70),
    hintStyle: const TextStyle(color: Colors.white54),
  ),
);
