// led_page.dart
import 'dart:developer';

import 'package:ambilight_app/layers/presentation/ui/pages/led/ambilight_page.dart';
import 'package:ambilight_app/layers/presentation/ui/pages/led/color_page.dart';
import 'package:flutter/material.dart';
import 'package:ambilight_app/layers/domain/entities/bluetooth_entity.dart';
import 'package:ambilight_app/layers/presentation/ui/widgets/button_header_widget.dart';
import 'package:flutter_blue_plus_windows/flutter_blue_plus_windows.dart';

class LedPage extends StatefulWidget {
  final BluetoothEntity bluetoothEntity;
  const LedPage({super.key, required this.bluetoothEntity});

  @override
  State<LedPage> createState() => _LedPageState();
}

class _LedPageState extends State<LedPage> {
  /// Controla o estado do LED (ligado ou desligado)
  bool isLedOn = false;

  final String serviceUuid = "0000ffff-0000-1000-8000-00805f9b34fb";
  final String writeUuid = "0000ff01-0000-1000-8000-00805f9b34fb";
  final String notifyUuid = "0000ff02-0000-1000-8000-00805f9b34fb";

  /// Comandos para ligar e desligar o LED
  final List<int> commandOn = [
    0x00,
    0x04,
    0x80,
    0x00,
    0x00,
    0x0D,
    0x0E,
    0x0B,
    0x3B,
    0x23,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x32,
    0x00,
    0x00,
    0x90
  ];
  final List<int> commandOff = [
    0x00,
    0x04,
    0x80,
    0x00,
    0x00,
    0x0D,
    0x0E,
    0x0B,
    0x3B,
    0x24,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x32,
    0x00,
    0x00,
    0x91
  ];

  @override
  void initState() {
    super.initState();
    _initializeConnection();
    _startListeningToNotifications();
  }

  Future<void> _startListeningToNotifications() async {
    try {
      log("[LedPage] Iniciando escuta de notificações...");

      // Descobre os serviços e características disponíveis no dispositivo
      List<BluetoothService> services =
          await widget.bluetoothEntity.device.discoverServices();

      BluetoothCharacteristic? notifyCharacteristic;
      for (final service in services) {
        if (service.uuid.str128.toString() == serviceUuid) {
          for (final characteristic in service.characteristics) {
            if (characteristic.uuid.str128.toString() == notifyUuid) {
              notifyCharacteristic = characteristic;
              log('[LedPage] Característica de notificação encontrada: ${characteristic.uuid.str128}');
              break;
            }
          }
        }
      }

      if (notifyCharacteristic == null) {
        log('[LedPage] ERRO: Característica de notificação não encontrada.',
            level: 1000);
        throw Exception("Característica de notificação não encontrada.");
      }

      await notifyCharacteristic.setNotifyValue(true);
      notifyCharacteristic.value.listen((value) {
        log('[LedPage] Notificação recebida: ${value}');
        if (value.length >= 21) {
          final checksum = value.sublist(8).reduce((a, b) => a + b) & 0xFF;
          if (checksum == value.last) {
            setState(() {
              isLedOn = value[9] == 0x23;
            });

            log('[LedPage] Estado do LED atualizado: ${isLedOn ? 'LIGADO' : 'DESLIGADO'}.');
          } else {
            log('[LedPage] Checksum inválido: $checksum != ${value.last}');
          }
        } else {
          log('[LedPage] Notificação com tamanho inválido: ${value.length}');
        }
      });
    } catch (e, stack) {
      log("[LedPage] Erro ao iniciar escuta de notificações: $e",
          error: e, stackTrace: stack);
    }
  }

  Future<void> _initializeConnection() async {
    try {
      if (!widget.bluetoothEntity.isConnected) {
        await widget.bluetoothEntity.connect();
      }
    } catch (e) {
      debugPrint("Erro ao conectar ao dispositivo: $e");
    }
  }

  Future<void> _toggleLed() async {
    log('[LedPage] _toggleLed chamado.');

    try {
      if (!(await widget.bluetoothEntity.device.isConnected)) {
        log('[LedPage] ERRO: O dispositivo não está conectado.');
        throw Exception("O dispositivo não está conectado.");
      }

      log('[LedPage] Descobrindo serviços...');
      List<BluetoothService> services =
          await widget.bluetoothEntity.device.discoverServices();

      log('[LedPage] Listando todos os serviços e características descobertos...');
      for (final service in services) {
        log('[LedPage] Serviço encontrado: ${service.uuid}');
        for (final characteristic in service.characteristics) {
          log('[LedPage] -> Característica encontrada: ${characteristic.uuid.str128}');
        }
      }

      BluetoothCharacteristic? writeCharacteristic;
      for (final service in services) {
        for (final characteristic in service.characteristics) {
          writeCharacteristic = characteristic;
          log('[LedPage] Característica de escrita encontrada: ${characteristic.uuid.str128}');
        }
      }

      if (writeCharacteristic == null) {
        log('[LedPage] ERRO: Característica de escrita não encontrada.',
            level: 1000);
        throw Exception("Característica de escrita não encontrada.");
      }

      final command = isLedOn ? commandOff : commandOn;
      log('[LedPage] Enviando comando: ${_bytesToHex(command)}');
      await writeCharacteristic.write(command, withoutResponse: true);
      log('[LedPage] Comando enviado com sucesso.');

      setState(() {
        isLedOn = !isLedOn;
      });
      log('[LedPage] Estado do LED atualizado: ${isLedOn ? 'LIGADO' : 'DESLIGADO'}.');
    } catch (e, stack) {
      log('[LedPage] ERRO ao alternar o estado do LED: $e',
          error: e, stackTrace: stack);
    }
  }

  String _bytesToHex(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  @override
  Widget build(BuildContext context) {
    final deviceName = widget.bluetoothEntity.device.name;

    // Lista de páginas (aba 0 e aba 1)
    // Lista de páginas (aba 0 e aba 1)
    final pages = [
      ColorPage(
        bluetoothEntity: widget.bluetoothEntity,
      ),
      AmbilightPage(
        bluetoothEntity: widget.bluetoothEntity,
      )
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(deviceName),
        actions: [
          // Botão de ligar/desligar no header
          ButtonHeaderWidget(
            onPressed: _toggleLed,
            widget: Icon(
              isLedOn ? Icons.lightbulb : Icons.lightbulb_outline,
              color: isLedOn ? Colors.yellow : Colors.grey,
              size: 30,
            ),
          ),
        ],
      ),
      // Exibe a tela correspondente (_currentIndex) sem perder estado
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      // BottomNavigationBar com duas abas: Cores e Config
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int newIndex) {
          setState(() => _currentIndex = newIndex);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.color_lens),
            label: 'Cores',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.energy_savings_leaf),
            label: 'Ambilight',
          ),
        ],
      ),
    );
  }

  /// Controla qual aba está selecionada (0 = Cores, 1 = Config)
  int _currentIndex = 0;
}
