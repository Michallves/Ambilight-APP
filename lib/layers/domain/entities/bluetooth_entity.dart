import 'dart:developer';
import 'package:flutter_blue_plus_windows/flutter_blue_plus_windows.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BluetoothEntity {
  final BluetoothDevice _device;

  /// Aqui armazenamos a lista de serviços descobertos no connect().
  List<BluetoothService>? _servicesCache;

  BluetoothEntity(this._device);

  BluetoothDevice get device => _device;

  String get name =>
      _device.advName.isNotEmpty ? _device.advName : 'Dispositivo Desconhecido';

  String get mac => _device.remoteId.toString();

  bool get isValid => name.startsWith('LED');

  bool get isConnected => _device.isConnected;

  Future<bool> get isConnectedLocalStorage async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('connection_$mac') ?? false;
  }

  /// Conecta ao dispositivo e salva o estado no SharedPreferences
  Future<void> connect() async {
    try {
      log('Tentando conectar ao dispositivo: $name',
          name: 'BluetoothEntity.connect');
      await _device.connect(autoConnect: true);

      // Faz a descoberta dos serviços e guarda em _servicesCache
      _servicesCache = await _device.discoverServices();

      // Apenas para logar no console
      for (final service in _servicesCache!) {
        log('Service: ${service.uuid}', name: 'BluetoothEntity.connect');
        for (final characteristic in service.characteristics) {
          log('Characteristic: ${characteristic.uuid}',
              name: 'BluetoothEntity.connect');
        }
      }

      // Salva o estado de conexão no SharedPreferences
      await _saveConnectionState(true);
      log('Conexão bem-sucedida com o dispositivo $name',
          name: 'BluetoothEntity.connect');
    } catch (e) {
      log('Erro ao conectar ao dispositivo $name: $e',
          name: 'BluetoothEntity.connect', error: e);
      throw Exception('Erro ao conectar ao dispositivo: $e');
    }
  }

  /// Desconecta do dispositivo e salva o estado no SharedPreferences
  Future<void> disconnect() async {
    try {
      log('Tentando desconectar do dispositivo: $name',
          name: 'BluetoothEntity.disconnect');
      await _device.disconnect();

      // Salva o estado de desconexão no SharedPreferences
      await _saveConnectionState(false);
      log('Dispositivo $name desconectado com sucesso',
          name: 'BluetoothEntity.disconnect');
    } catch (e) {
      log('Erro ao desconectar do dispositivo $name: $e',
          name: 'BluetoothEntity.disconnect', error: e);
      throw Exception('Erro ao desconectar do dispositivo: $e');
    }
  }

  /// Salva o estado de conexão no SharedPreferences
  Future<void> _saveConnectionState(bool isConnected) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('connection_$mac', isConnected);
    log('Estado de conexão salvo para $name: $isConnected',
        name: 'BluetoothEntity._saveConnectionState');
  }

  @override
  String toString() {
    return 'BluetoothEntity(name: $name, mac: $mac)';
  }
}
