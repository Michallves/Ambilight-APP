import 'dart:developer';
import 'package:ambilight_app/layers/domain/entities/device_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus_windows/flutter_blue_plus_windows.dart';

class BluetoothProvider with ChangeNotifier {
  bool isBluetoothEnabled = false;
  bool isScanning = false;
  List<DeviceEntity> bluetoothDevices =
      []; // Lista de dispositivos Bluetooth válidos

  /// Verifica o estado do adaptador Bluetooth.
  Future<void> checkBluetoothState() async {
    log(
      'Iniciando a verificação do estado do Bluetooth...',
      name: 'BluetoothProvider.checkBluetoothState',
      time: DateTime.now(),
    );

    if (await FlutterBluePlus.isSupported == false) {
      log(
        'Bluetooth não é suportado neste dispositivo.',
        name: 'BluetoothProvider.checkBluetoothState',
        time: DateTime.now(),
      );
      isBluetoothEnabled = false;
      notifyListeners();
      return;
    }

    try {
      log(
        'Obtendo o estado do adaptador Bluetooth...',
        name: 'BluetoothProvider.checkBluetoothState',
        time: DateTime.now(),
      );

      FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
        log(
          'Estado do Bluetooth atualizado: $state',
          name: 'BluetoothProvider.checkBluetoothState',
          time: DateTime.now(),
        );
        isBluetoothEnabled = (state == BluetoothAdapterState.on);
        if (isBluetoothEnabled) {
          startScanning(); // Inicia o escaneamento
        } else {
          stopScanning(); // Para o escaneamento
          bluetoothDevices.clear(); // Limpa a lista de dispositivos
        }
        notifyListeners();
      });
    } catch (e) {
      log(
        'Erro ao verificar o estado do Bluetooth: $e',
        name: 'BluetoothProvider.checkBluetoothState',
        time: DateTime.now(),
        error: e,
      );
      isBluetoothEnabled = false;
      notifyListeners();
    }
  }

  Future<void> startScanning() async {
    if (!isBluetoothEnabled) {
      log('Bluetooth está desabilitado. Não é possível iniciar o escaneamento.',
          name: 'BluetoothProvider.startScanning');
      return;
    }

    log('Iniciando escaneamento...', name: 'BluetoothProvider.startScanning');
    isScanning = true;
    bluetoothDevices.clear();
    notifyListeners();

    FlutterBluePlus.startScan();

    FlutterBluePlus.scanResults.expand((e) => e).listen((scanResult) async {
      final entity = DeviceEntity(scanResult.device);

      if (entity.isCompatible) {
        // Adiciona à lista e notifica mudanças
        if (!bluetoothDevices.any((device) => device.mac == entity.mac)) {
          bluetoothDevices.add(entity);
          log('Novo dispositivo adicionado: $entity',
              name: 'BluetoothProvider.startScanning');
          notifyListeners();
        }
      }
    });
  }

  /// Para o escaneamento de dispositivos Bluetooth.
  Future<void> stopScanning() async {
    if (!isScanning) return;

    log(
      'Parando escaneamento de dispositivos Bluetooth...',
      name: 'BluetoothProvider.stopScanning',
      time: DateTime.now(),
    );

    FlutterBluePlus.stopScan();
    isScanning = false;
    notifyListeners();
  }
}
