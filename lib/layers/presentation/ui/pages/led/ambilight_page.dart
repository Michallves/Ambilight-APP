import 'dart:async';
import 'dart:developer';
import 'package:ambilight_app/core/utils/gdi_capture.dart';
import 'package:ambilight_app/core/utils/image_processor.dart';
import 'package:flutter/material.dart';
import 'package:ambilight_app/layers/domain/entities/device_entity.dart';
import 'package:flutter_blue_plus_windows/flutter_blue_plus_windows.dart';

class AmbilightPage extends StatefulWidget {
  final DeviceEntity deviceEntity;

  const AmbilightPage({super.key, required this.deviceEntity});

  @override
  AmbilightPageState createState() => AmbilightPageState();
}

class AmbilightPageState extends State<AmbilightPage> {
  bool isAmbilightOn = false; // Estado do modo Ambilight
  final String serviceUuid = "0000ffff-0000-1000-8000-00805f9b34fb";
  final String writeUuid = "0000ff01-0000-1000-8000-00805f9b34fb";
  HSVColor _currentColor = HSVColor.fromColor(Colors.black);

  @override
  void dispose() {
    super.dispose();
  }

  void _toggleAmbilight() {
    setState(() {
      isAmbilightOn = !isAmbilightOn;
      if (isAmbilightOn) {
        _startAmbilight();
      } else {
        _stopAmbilight();
      }
    });
  }

  void _startAmbilight() {
    log("[Ambilight] Modo Ambilight ativado.");
    _captureScreenshotsContinuously();
  }

  void _stopAmbilight() {
    log("[Ambilight] Modo Ambilight desativado.");
    isAmbilightOn = false; // Interrompe o loop
  }

  Future<void> _captureScreenshotsContinuously() async {
    final capture = GDICapture();
    final processor = ImageProcessor();
    int frameCount = 0;

    // Intervalo mínimo para 30 FPS (1000ms / 30 = ~33ms por quadro)
    const int frameIntervalMs = 33;

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isAmbilightOn) {
        timer.cancel();
        capture.dispose();
        return;
      }
      log("[Ambilight] FPS atual: $frameCount");
      frameCount = 0;
    });

    while (isAmbilightOn) {
      final startTime = DateTime.now();

      try {
        // Captura a tela
        final screenshot = capture.captureScreen(width: 800, height: 600);
        if (screenshot != null) {
          frameCount++;
          // Processa a cor ambiente
          final ambientColor = processor.calculateAmbientColor(
            screenshot,
            800,
            600,
          );
          setState(() {
            _currentColor = ambientColor;
          });
          _setColorAsync(_currentColor);

          log("[Ambilight] Cor ambiente calculada: $ambientColor");
        } else {
          log("[Ambilight] Falha na captura de tela.");
        }
      } catch (e) {
        log("[Ambilight] Erro na captura: $e");
      }

      final elapsedTime = DateTime.now().difference(startTime).inMilliseconds;

      // Garante que o intervalo mínimo entre quadros seja respeitado
      final delay = (frameIntervalMs - elapsedTime).clamp(0, frameIntervalMs);
      await Future.delayed(Duration(milliseconds: delay));
    }
  }

  HSVColor? _lastSentColor;
  Future<void> _setColorAsync(HSVColor color) async {
    Future.microtask(() => _setColor(color));
  }

  Future<void> _setColor(HSVColor color) async {
    // Define uma tolerância para mudanças de cor
    const double hueTolerance = 5.0;
    const double saturationTolerance = 0.05;
    const double brightnessTolerance = 0.05;

    // Verifica se a nova cor está dentro da tolerância
    if (_lastSentColor != null &&
        (color.hue - _lastSentColor!.hue).abs() < hueTolerance &&
        (color.saturation - _lastSentColor!.saturation).abs() <
            saturationTolerance &&
        (color.value - _lastSentColor!.value).abs() < brightnessTolerance) {
      log("[Ambilight] Mudança de cor insignificante. Não enviando.");
      return;
    }

    try {
      log("[Ambilight] Alterando a cor para: $color");
      final packet = _colorToPacket(color);
      final writeCharacteristic = await _findWriteCharacteristic();

      if (writeCharacteristic == null) {
        throw Exception("Característica de escrita não encontrada.");
      }

      await writeCharacteristic.write(packet, withoutResponse: true);
      _lastSentColor = color; // Atualiza a última cor enviada
      log("[Ambilight] Cor enviada com sucesso!");
    } catch (e) {
      log("[Ambilight] Erro ao enviar cor: $e");
    }
  }

  BluetoothCharacteristic? _cachedWriteCharacteristic;

  Future<BluetoothCharacteristic?> _findWriteCharacteristic() async {
    if (_cachedWriteCharacteristic != null) {
      return _cachedWriteCharacteristic;
    }

    final services = await widget.deviceEntity.device.discoverServices();
    for (final service in services) {
      if (service.uuid.str128.toString() == serviceUuid) {
        for (final characteristic in service.characteristics) {
          if (characteristic.uuid.str128.toString() == writeUuid) {
            _cachedWriteCharacteristic = characteristic;
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
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ambilight'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: isDesktop ? height / 8 : height / 16),
                const Text(
                  'Modo Ambilight',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                if (isDesktop)
                  // Layout para desktop: círculo e botão lado a lado
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Círculo colorido
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 430,
                        height: 430,
                        decoration: BoxDecoration(
                          color: isAmbilightOn
                              ? _currentColor.toColor()
                              : Colors.black,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 110),
                      // Botão de ligar/desligar e texto
                      Column(
                        children: [
                          IconButton(
                            onPressed: _toggleAmbilight,
                            style: IconButton.styleFrom(
                              padding: const EdgeInsets.all(20),
                              backgroundColor:
                                  isAmbilightOn ? Colors.green : Colors.red,
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
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(width: 205),
                    ],
                  )
                else
                  // Layout para dispositivos móveis: tudo em coluna
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Círculo colorido
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 330,
                        height: 330,
                        decoration: BoxDecoration(
                          color: isAmbilightOn
                              ? _currentColor.toColor()
                              : Colors.black,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Botão de ligar/desligar e texto
                      IconButton(
                        onPressed: _toggleAmbilight,
                        style: IconButton.styleFrom(
                          padding: const EdgeInsets.all(20),
                          backgroundColor:
                              isAmbilightOn ? Colors.green : Colors.red,
                        ),
                        icon: Icon(
                          Icons.power_settings_new,
                          color: isAmbilightOn
                              ? Colors.white
                              : Theme.of(context).scaffoldBackgroundColor,
                          size: 80,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isAmbilightOn ? "Ligado" : "Desligado",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
