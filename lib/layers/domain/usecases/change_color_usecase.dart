import 'package:ambilight_app/core/config/bluetooth_config.dart';
import 'package:ambilight_app/layers/domain/entities/device_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus_windows/flutter_blue_plus_windows.dart';

abstract class ChangeColorUsecase {
  Future<void> call(DeviceEntity deviceEntity, HSVColor color);
}

class ChangeColorUsecaseImpl implements ChangeColorUsecase {
  List<int> colorToPacket(HSVColor color) {
    int hue = (color.hue / 360 * 181).toInt();
    int saturation = (color.saturation * 100).toInt();
    int alpha = (color.value * 100).toInt();

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

  @override
  Future<void> call(DeviceEntity deviceEntity, HSVColor color) async {
    try {
      final packet = colorToPacket(color);

      List<BluetoothService> services =
          await deviceEntity.device.discoverServices();

      BluetoothCharacteristic? writeCharacteristic;
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
      }

      if (writeCharacteristic == null) {
        throw Exception("Característica de escrita não encontrada.");
      }

      return await writeCharacteristic.write(packet, withoutResponse: true);
    } catch (e) {
      throw Exception('Erro ao enviar o comando para o LED: $e');
    }
  }
}
