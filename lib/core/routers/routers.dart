import 'package:ambilight_app/layers/domain/entities/bluetooth_entity.dart';
import 'package:ambilight_app/layers/presentation/ui/pages/error/error_page.dart';
import 'package:ambilight_app/layers/presentation/ui/pages/home/home_page.dart';
import 'package:ambilight_app/layers/presentation/ui/pages/led/led_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final routers = GoRouter(
  initialLocation: '/',
  errorBuilder: (BuildContext context, GoRouterState state) =>
      const ErrorPage(),
  routes: <GoRoute>[
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
      routes: <GoRoute>[
        GoRoute(
          path: 'led/:mac',
          builder: (context, state) {
            final BluetoothEntity bluetoothEntity = state.extra as BluetoothEntity;
            return LedPage(bluetoothEntity: bluetoothEntity);
          },
        ),
      ],
    ),
  ],
);
