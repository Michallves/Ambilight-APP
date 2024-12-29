import 'package:ambilight_app/layers/domain/entities/device_entity.dart';
import 'package:ambilight_app/layers/presentation/ui/pages/config/about_page.dart';
import 'package:ambilight_app/layers/presentation/ui/pages/config/config_page.dart';
import 'package:ambilight_app/layers/presentation/ui/pages/error/error_page.dart';
import 'package:ambilight_app/layers/presentation/ui/pages/home/home_page.dart';
import 'package:ambilight_app/layers/presentation/ui/pages/led/divce_about_page.dart';
import 'package:ambilight_app/layers/presentation/ui/pages/led/ambilight_page.dart';
import 'package:ambilight_app/layers/presentation/ui/pages/led/color_page.dart';
import 'package:ambilight_app/layers/presentation/ui/pages/led/led_page.dart';
import 'package:ambilight_app/layers/presentation/ui/pages/led/toggle_led_page.dart';
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
          path: 'config',
          builder: (context, state) => const ConfigPage(),
          routes: <GoRoute>[
                    GoRoute(
                path: 'about',
                builder: (context, state) => const AboutPage(),
              ),
          ]
        ),
        GoRoute(
          path: 'led/:mac',
          builder: (context, state) {
            final DeviceEntity deviceEntity = state.extra as DeviceEntity;
            return LedPage(deviceEntity: deviceEntity);
          },
          routes: <GoRoute>[
            GoRoute(
              path: 'toggle',
              builder: (context, state) {
                final DeviceEntity deviceEntity = state.extra as DeviceEntity;
                return ToggleLedPage(deviceEntity: deviceEntity);
              },
            ),
            GoRoute(
              path: 'color',
              builder: (context, state) {
                final DeviceEntity deviceEntity = state.extra as DeviceEntity;
                return ColorPage(deviceEntity: deviceEntity);
              },
            ),
            GoRoute(
              path: 'ambilight',
              builder: (context, state) {
                final DeviceEntity deviceEntity = state.extra as DeviceEntity;
                return AmbilightPage(deviceEntity: deviceEntity);
              },
            ),
            GoRoute(
              path: 'about',
              builder: (context, state) {
                final DeviceEntity deviceEntity = state.extra as DeviceEntity;
                return DeviceAboutPage(deviceEntity: deviceEntity);
              },
            ),
          ],
        ),
      ],
    ),
  ],
);
