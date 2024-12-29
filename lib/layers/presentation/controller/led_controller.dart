import 'package:ambilight_app/layers/domain/entities/device_entity.dart';
import 'package:ambilight_app/layers/domain/usecases/change_color_usecase.dart';
import 'package:ambilight_app/layers/domain/usecases/turn_off_led_usecase.dart';
import 'package:ambilight_app/layers/domain/usecases/turn_on_led_usecase.dart';
import 'package:flutter/material.dart';

class LedController {
  final TurnOnLedUsecase _turnOnLedUsecase;
  final TurnOffLedUsecase _turnOffLedUsecase;
  final ChangeColorUsecase _changeColorUsecase;

  LedController(this._turnOnLedUsecase, this._turnOffLedUsecase,
      this._changeColorUsecase);

  Future<void> turnOnLed(DeviceEntity deviceEntity) async {
    await _turnOnLedUsecase.call(deviceEntity);
  }

  Future<void> turnOffLed(DeviceEntity deviceEntity) async {
    await _turnOffLedUsecase.call(deviceEntity);
  }

  Future<void> changeColor(DeviceEntity deviceEntity, HSVColor color) async {
    await _changeColorUsecase.call(deviceEntity, color);
  }
}
