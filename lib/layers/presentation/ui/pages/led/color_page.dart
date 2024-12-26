import 'dart:developer';
import 'package:ambilight_app/core/utils/color_decoder.dart';
import 'package:flutter/material.dart';
import 'package:ambilight_app/layers/domain/entities/bluetooth_entity.dart';
import 'package:flutter_blue_plus_windows/flutter_blue_plus_windows.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPage extends StatefulWidget {
  final BluetoothEntity bluetoothEntity;

  const ColorPage({
    Key? key,
    required this.bluetoothEntity,
  }) : super(key: key);

  @override
  _ColorPageState createState() => _ColorPageState();
}

class _ColorPageState extends State<ColorPage> {
  /// UUIDs do serviço e características (baseados no Python)
  final String serviceUuid = "0000ffff-0000-1000-8000-00805f9b34fb";
  final String writeUuid = "0000ff01-0000-1000-8000-00805f9b34fb";
  final String notifyUuid = "0000ff02-0000-1000-8000-00805f9b34fb";

  Color currentColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _startListeningToNotifications();
  }

  List<int> _colorToPacket(HSVColor color) {
    int hue = (color.hue / 360 * 181).toInt(); // Matiz (0-360)
    int saturation = (color.saturation * 100).toInt(); // Saturação (0-100)
    int alpha = (color.value * 100).toInt(); // Valor (Brightness) em 0-100

    final List<int> payload = [
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
      alpha,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00
    ];

    return payload;
  }

  Future<void> _startListeningToNotifications() async {
    try {
      log("[ColorPage] Iniciando escuta de notificações...");

      // Descobre os serviços e características disponíveis no dispositivo
      List<BluetoothService> services =
          await widget.bluetoothEntity.device.discoverServices();

      BluetoothCharacteristic? notifyCharacteristic;
      for (final service in services) {
        if (service.uuid.str128.toString() == serviceUuid) {
          for (final characteristic in service.characteristics) {
            if (characteristic.uuid.str128.toString() == notifyUuid) {
              notifyCharacteristic = characteristic;
              log('[ColorPage] Característica de notificação encontrada: ${characteristic.uuid.str128}');
              break;
            }
          }
        }
      }

      if (notifyCharacteristic == null) {
        log('[ColorPage] ERRO: Característica de notificação não encontrada.',
            level: 1000);
        throw Exception("Característica de notificação não encontrada.");
      }

      await notifyCharacteristic.setNotifyValue(true);
      notifyCharacteristic.value.listen((value) {
        log("[ColorPage] Notificação recebida: ${_bytesToHex(value)}");
        final hexData = _bytesToHex(value);
        final colorMap = ColorDecoder.parseColor(hexData);

        if (colorMap != null) {
          final color = Color.fromARGB(
              255, colorMap['r']!, colorMap['g']!, colorMap['b']!);

          log("[ColorPage] Cor atual atualizada via notificação para: $color");
        } else {
          log("[ColorPage] Falha ao decodificar a cor.");
        }
      });
    } catch (e, stack) {
      log("[ColorPage] Erro ao iniciar escuta de notificações: $e",
          error: e, stackTrace: stack);
    }
  }

  String _bytesToHex(List<int> bytes) {
    final buffer = StringBuffer();
    for (final byte in bytes) {
      buffer.write(byte.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }

  Future<void> _setColor(HSVColor color) async {
    try {
      log("[ColorPage] Tentando alterar a cor para: $color");

      // Converte a cor selecionada para o formato esperado pelo dispositivo
      final packet = _colorToPacket(color);

      // Descobre os serviços e características disponíveis no dispositivo
      log('[LedPage] Descobrindo serviços...');
      List<BluetoothService> services =
          await widget.bluetoothEntity.device.discoverServices();
      log("[ColorPage] Serviços descobertos: ${services.length}");

      log('[LedPage] Listando todos os serviços e características descobertos...');
      for (final service in services) {
        log('[LedPage] Serviço encontrado: ${service.uuid}');
        for (final characteristic in service.characteristics) {
          log('[LedPage] -> Característica encontrada: ${characteristic.uuid.str128}');
        }
      }

      BluetoothCharacteristic? writeCharacteristic;
      for (final service in services) {
        if (service.uuid.str128.toString() == serviceUuid) {
          for (final characteristic in service.characteristics) {
            if (characteristic.uuid.str128.toString() == writeUuid) {
              writeCharacteristic = characteristic;
              log('[LedPage] Característica de escrita encontrada: ${characteristic.uuid.str128}');
              break;
            }
          }
        }
      }

      if (writeCharacteristic == null) {
        log('[LedPage] ERRO: Característica de escrita não encontrada.',
            level: 1000);
        throw Exception("Característica de escrita não encontrada.");
      }

      // Envia o comando para o dispositivo
      log("[ColorPage] Enviando comando: ${_bytesToHex(packet)}");
      await writeCharacteristic.write(packet, withoutResponse: true);
      log("[ColorPage] Comando enviado com sucesso!");
    } catch (e, stack) {
      log("[ColorPage] Erro ao setar cor: $e", error: e, stackTrace: stack);
    }
  }

  void changeColor(HSVColor color) {
    _setColor(color);
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 600;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Cores',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Center(
              child: SizedBox(
                width: isDesktop ? 900 : 500,
                child: ColorPicker(
                  pickerColor: currentColor,
                  onColorChanged: (_) => {},
                  onHsvColorChanged: changeColor,
                  paletteType: PaletteType.hueWheel,
                  colorPickerWidth: 450,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
