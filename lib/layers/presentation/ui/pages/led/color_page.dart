import 'package:ambilight_app/layers/presentation/controller/led_controller.dart';
import 'package:flutter/material.dart';
import 'package:ambilight_app/layers/domain/entities/device_entity.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get_it/get_it.dart';

class ColorPage extends StatefulWidget {
  final DeviceEntity deviceEntity;

  const ColorPage({
    super.key,
    required this.deviceEntity,
  });

  @override
  _ColorPageState createState() => _ColorPageState();
}

class _ColorPageState extends State<ColorPage> {
  final LedController _ledController = GetIt.I.get<LedController>();

  Color currentColor = Colors.white;

  @override
  void initState() {
    super.initState();
  }

  void changeColor(HSVColor color) {
    _ledController.changeColor(widget.deviceEntity, color);
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cores'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: isDesktop ? height / 8 : height / 16),
              const Text(
                'Cores',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: isDesktop ? 900 : 500,
                  child: ColorPicker(
                    pickerColor: currentColor,
                    onColorChanged: (_) => {},
                    onHsvColorChanged: changeColor,
                    paletteType: PaletteType.hueWheel,
                    colorPickerWidth: isDesktop ? 450 : 350,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
