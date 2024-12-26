import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPickerWidget extends StatefulWidget {
  const ColorPickerWidget({Key? key}) : super(key: key);

  @override
  State<ColorPickerWidget> createState() => _ColorPickerWidgetState();
}

class _ColorPickerWidgetState extends State<ColorPickerWidget> {
  Color _tempColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Escolha a cor'),
      content: BlockPicker(
        pickerColor: _tempColor,
        onColorChanged: (color) {
          setState(() {
            _tempColor = color;
          });
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_tempColor),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
