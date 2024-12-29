// ignore_for_file: constant_pattern_never_matches_value_type

import 'dart:developer';
import 'package:ambilight_app/layers/domain/entities/enums/bluetooth_divice_type.dart';
import 'package:ambilight_app/layers/domain/entities/enums/device_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus_windows/flutter_blue_plus_windows.dart';

class DeviceEntity {
  final BluetoothDevice _device;
  List<BluetoothService>? _servicesCache;

  DeviceEntity(this._device);

  BluetoothDevice get device => _device;

  String get name =>
      _device.advName.isNotEmpty ? _device.advName : 'Dispositivo Desconhecido';

  String get mac => _device.remoteId.toString();

  bool get isCompatible => type == DeviceType.LED;

  String get typeName {
    switch (type) {
      case DeviceType.LED:
        return 'Fita de LED';
      case DeviceType.UNKNOWN:
      default:
        return 'Desconhecido';
    }
  }

  DeviceType get type {
    if (_device.platformName.contains('LEDnetWF')) {
      return DeviceType.LED;
    } else {
      return DeviceType.UNKNOWN;
    }
  }

  IconData get icon {
    switch (type) {
      case DeviceType.LED:
        return Icons.lightbulb;
      case DeviceType.UNKNOWN:
      default:
        return Icons.bluetooth;
    }
  }

  String get bluetoothDeviceTypeName {
    switch (bluetoothDeviceType) {
      case BluetoothDeviceType.LE:
        return 'Bluetooth Low Energy';
      case BluetoothDeviceType.CLASSIC:
        return 'Bluetooth Clássico';
      case BluetoothDeviceType.UNKNOWN:
      default:
        return 'Desconhecido';
    }
  }

  BluetoothDeviceType get bluetoothDeviceType {
    if (device.mtuNow == 23) {
      return BluetoothDeviceType.LE;
    } else if (device.mtuNow > 23) {
      return BluetoothDeviceType.CLASSIC;
    }
    return BluetoothDeviceType.UNKNOWN;
  }

  bool get isConnected => _device.isConnected;

  /// Conecta ao dispositivo e salva o estado no SharedPreferences
  Future<void> connect() async {
    try {
      log('Tentando conectar ao dispositivo: $name',
          name: 'deviceEntity.connect');
      await _device.connect(autoConnect: true);

      // Faz a descoberta dos serviços e guarda em _servicesCache
      _servicesCache = await _device.discoverServices();

      // Apenas para logar no console
      for (final service in _servicesCache!) {
        log('Service: ${service.uuid}', name: 'deviceEntity.connect');
        for (final characteristic in service.characteristics) {
          log('Characteristic: ${characteristic.uuid}',
              name: 'deviceEntity.connect');
        }
      }
    } catch (e) {
      log('Erro ao conectar ao dispositivo $name: $e',
          name: 'deviceEntity.connect', error: e);
      throw Exception('Erro ao conectar ao dispositivo: $e');
    }
  }

  /// Desconecta do dispositivo e salva o estado no SharedPreferences
  Future<void> disconnect() async {
    try {
      log('Tentando desconectar do dispositivo: $name',
          name: 'deviceEntity.disconnect');
      await _device.disconnect();

      log('Dispositivo $name desconectado com sucesso',
          name: 'deviceEntity.disconnect');
    } catch (e) {
      log('Erro ao desconectar do dispositivo $name: $e',
          name: 'deviceEntity.disconnect', error: e);
      throw Exception('Erro ao desconectar do dispositivo: $e');
    }
  }

  @override
  String toString() {
    return 'DeviceEntity(name: $name, mac: $mac)';
  }
}
