import 'dart:developer';

import 'package:ambilight_app/layers/domain/entities/device_entity.dart';
import 'package:ambilight_app/layers/presentation/controller/led_controller.dart';
import 'package:ambilight_app/layers/presentation/ui/widgets/snackbars.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ToggleLedPage extends StatefulWidget {
  final DeviceEntity deviceEntity;
  const ToggleLedPage({super.key, required this.deviceEntity});

  @override
  State<ToggleLedPage> createState() => _ToggleLedPageState();
}

class _ToggleLedPageState extends State<ToggleLedPage> {
  final LedController _ledController = GetIt.I.get<LedController>();
  bool isLedOn = false;

  Future<void> _toggleLed() async {
    if (isLedOn) {
      try {
        await _ledController.turnOffLed(widget.deviceEntity);
        setState(() {
          isLedOn = false;
        });
      } catch (e, stack) {
        log('Erro ao desligar o LED: $e', error: e, stackTrace: stack);
        SnackBars.error(context, message: 'Erro ao desligar o LED.');
      }
    } else {
      try {
        await _ledController.turnOnLed(widget.deviceEntity);
        setState(() {
          isLedOn = true;
        });
      } catch (e, stack) {
        log('Erro ao ligar o LED: $e', error: e, stackTrace: stack);
        SnackBars.error(context, message: 'Erro ao ligar o LED.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(title: const Text('Ligar/Desligar')),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: height / 8),
              Icon(
                isLedOn ? Icons.lightbulb : Icons.lightbulb_outline,
                color: isLedOn ? Colors.yellow : Colors.grey,
                size: isDesktop ? 300 : 150,
              ),
              const SizedBox(height: 100),
              IconButton(
                onPressed: _toggleLed,
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                  backgroundColor: isLedOn ? Colors.green : Colors.red,
                ),
                icon: Icon(
                  Icons.power_settings_new,
                  color: isLedOn
                      ? Colors.white
                      : Theme.of(context).scaffoldBackgroundColor,
                  size: isDesktop ? 100 : 50,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isLedOn ? "Ligado" : "Desligado",
                style: TextStyle(
                    fontSize: isDesktop ? 20 : 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
