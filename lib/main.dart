import 'package:ambilight_app/core/inject/inject.dart';
import 'package:ambilight_app/core/theme/app_dark_theme.dart';
import 'package:ambilight_app/core/theme/app_light_theme.dart';
import 'package:ambilight_app/layers/presentation/provider/bluetooth_provider.dart';
import 'package:flutter/material.dart';
import 'package:ambilight_app/core/routers/routers.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding
      .ensureInitialized(); // Inicializa os bindings do Flutter
  Inject.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BluetoothProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Ambilight App',
      debugShowCheckedModeBanner: false,
      theme: appLightThemeData, // Define o tema claro do app
      darkTheme: appDarkThemeData, // Define o tema personalizado do app
      themeMode: ThemeMode.system,
      routerDelegate: routers.routerDelegate, // Define o delegado do roteador
      routeInformationParser:
          routers.routeInformationParser, // Parser de informações de rota
      routeInformationProvider: routers.routeInformationProvider,
    );
  }
}
