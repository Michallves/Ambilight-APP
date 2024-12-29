import 'package:ambilight_app/core/config/bluetooth_config.dart';
import 'package:ambilight_app/layers/domain/entities/device_entity.dart';
import 'package:flutter_blue_plus_windows/flutter_blue_plus_windows.dart';

abstract class TurnOffLedUsecase {
  Future<void> call(DeviceEntity deviceEntity);
}

class TurnOffLedUsecaseImpl implements TurnOffLedUsecase {
  static final List<int> commandOff = [
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
  Future<void> call(DeviceEntity deviceEntity) async {
    try {
      // Descobre os serviços disponíveis
      List<BluetoothService> services =
          await deviceEntity.device.discoverServices();

      BluetoothCharacteristic? writeCharacteristic;

      // Procura a característica de escrita com base nos UUIDs configurados
      for (final service in services) {
        if (service.uuid.str128.toString() == BluetoothConfig.serviceUuid) {
          for (final characteristic in service.characteristics) {
            if (characteristic.uuid.str128.toString() ==
                BluetoothConfig.writeUuid) {
              writeCharacteristic = characteristic;
              break;
            }
          }
        }
        if (writeCharacteristic != null) break;
      }

      if (writeCharacteristic == null) {
        throw Exception(
            "Característica de escrita não encontrada. Verifique o dispositivo.");
      }

      // Escreve o comando na característica
      await writeCharacteristic.write(commandOff, withoutResponse: true);
    } catch (e) {
      // Lança a exceção para ser tratada na interface
      throw Exception("Erro ao ligar o LED: $e");
    }
  }
}
