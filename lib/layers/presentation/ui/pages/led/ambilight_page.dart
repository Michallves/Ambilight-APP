import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';
import 'dart:ui';
import 'package:ambilight_app/core/utils/ambilight_color_processor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ambilight_app/layers/domain/entities/bluetooth_entity.dart';
import 'package:flutter_blue_plus_windows/flutter_blue_plus_windows.dart';
import 'package:desktop_screenshot/desktop_screenshot.dart';
import 'package:palette_generator/palette_generator.dart';

class AmbilightPage extends StatefulWidget {
  final BluetoothEntity bluetoothEntity;

  const AmbilightPage({super.key, required this.bluetoothEntity});

  @override
  AmbilightPageState createState() => AmbilightPageState();
}

class AmbilightPageState extends State<AmbilightPage> {
  bool isAmbilightOn = false; // Estado do modo Ambilight
  Timer? _ambilightTimer; // Timer para capturar a tela periodicamente
  HSVColor _currentColor = HSVColor.fromColor(Colors.black);
  final DesktopScreenshot _desktopScreenshot = DesktopScreenshot();

  final String serviceUuid = "0000ffff-0000-1000-8000-00805f9b34fb";
  final String writeUuid = "0000ff01-0000-1000-8000-00805f9b34fb";

  @override
  void dispose() {
    _ambilightTimer?.cancel();
    super.dispose();
  }

  void _toggleAmbilight() {
    setState(() {
      isAmbilightOn = !isAmbilightOn;
      isAmbilightOn ? _startAmbilight() : _stopAmbilight();
    });
  }

  void _startAmbilight() async {
    log("[Ambilight] Modo Ambilight ativado.");
    for (;;) {
      if (!isAmbilightOn) break;
      await _captureAndProcessScreen();
    }
  }

  void _stopAmbilight() {
    log("[Ambilight] Modo Ambilight desativado.");
    _ambilightTimer?.cancel();
    _ambilightTimer = null;

    setState(() {
      _currentColor = HSVColor.fromColor(Colors.black);
    });

    _setColor(_currentColor);
  }

  Future<void> _captureAndProcessScreen() async {
    try {
      // Captura a tela como Uint8List
      final screenshot = await _desktopScreenshot.getScreenshot();

      if (screenshot == null || screenshot.isEmpty) {
        log("[Ambilight] Falha ao capturar a tela.");
        return;
      }

      // Processa a cor ambiente da imagem
      final colorProcessor = AmbilightColorProcessor();
      final ambientColor =
          await colorProcessor.processAmbilightColors(screenshot);

      // Atualiza o estado e envia a cor para a fita LED
      setState(() {
        _currentColor = HSVColor.fromColor(ambientColor);
      });
      _setColor(_currentColor);

      log("[Ambilight] Cor ambiente processada com sucesso: $ambientColor");
    } catch (e) {
      log("[Ambilight] Erro ao capturar ou processar a tela: $e", level: 1000);
    }
  }

  Future<HSVColor> processImage(Uint8List screenshot) async {
    return await compute(_processImage, screenshot);
  }

  Future<HSVColor> _processImage(Uint8List screenshot) async {
    final paletteGenerator =
        await PaletteGenerator.fromImageProvider(MemoryImage(screenshot));
    final dominantColor = paletteGenerator.dominantColor?.color ?? Colors.black;
    return HSVColor.fromColor(dominantColor);
  }

  Future<void> _setColor(HSVColor color) async {
    try {
      log("[Ambilight] Alterando a cor para: $color");
      final packet = _colorToPacket(color);
      final writeCharacteristic = await _findWriteCharacteristic();

      if (writeCharacteristic == null) {
        throw Exception("Característica de escrita não encontrada.");
      }

      await writeCharacteristic.write(packet, withoutResponse: true);
      log("[Ambilight] Cor enviada com sucesso!");
    } catch (e) {
      log("[Ambilight] Erro ao enviar cor: $e");
    }
  }

  Future<BluetoothCharacteristic?> _findWriteCharacteristic() async {
    final services = await widget.bluetoothEntity.device.discoverServices();
    for (final service in services) {
      if (service.uuid.str128.toString() == serviceUuid) {
        for (final characteristic in service.characteristics) {
          if (characteristic.uuid.str128.toString() == writeUuid) {
            return characteristic;
          }
        }
      }
    }
    return null;
  }

  List<int> _colorToPacket(HSVColor color) {
    int hue = (color.hue / 360 * 181).toInt();
    int saturation = (color.saturation * 100).toInt();
    int brightness = (color.value * 100).toInt();

    return [
      0x00,
      0x05,
      0x80,
      0x00,
      0x00,
      0x0D,
      0x0E,
      0x0B,
      0x3B,
      0xA1,
      hue,
      saturation,
      brightness,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Modo Ambilight',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 50),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: _currentColor.toColor(),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 50),
              IconButton(
                onPressed: _toggleAmbilight,
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                  backgroundColor: isAmbilightOn ? Colors.green : Colors.red,
                ),
                icon: Icon(
                  Icons.power_settings_new,
                  color: isAmbilightOn
                      ? Colors.white
                      : Theme.of(context).scaffoldBackgroundColor,
                  size: 100,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isAmbilightOn ? "Ligado" : "Desligado",
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
