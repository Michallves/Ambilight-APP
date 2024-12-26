import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:palette_generator/palette_generator.dart';

class AmbilightColorProcessor {
  Future<Color> processAmbilightColors(Uint8List imageBytes) async {
    final image = MemoryImage(imageBytes);
    final paletteGenerator = await PaletteGenerator.fromImageProvider(image);

    if (paletteGenerator.colors.isEmpty) {
      throw Exception("Falha ao processar as cores.");
    }

    // Aqui você pode dividir a imagem em sub-regiões e calcular cores para cada
    // Exemplo simples: usa apenas a cor predominante
    final dominantColor = paletteGenerator.dominantColor?.color ?? Colors.black;

    // Retorna as mesmas cores para simular as bordas
    return _enhanceColor(dominantColor);
  }
  

  Color _calculateAverageColor(img.Image image) {
    int totalRed = 0, totalGreen = 0, totalBlue = 0;

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        totalRed += img.getRed(pixel);
        totalGreen += img.getGreen(pixel);
        totalBlue += img.getBlue(pixel);
      }
    }

    final numPixels = image.width * image.height;
    return Color.fromARGB(
      255,
      (totalRed / numPixels).round(),
      (totalGreen / numPixels).round(),
      (totalBlue / numPixels).round(),
    );
  }

  Color _enhanceColor(Color color) {
    final hsvColor = HSVColor.fromColor(color);

    // Aumenta a saturação e o brilho para destacar o efeito
    final enhancedColor = hsvColor
        .withSaturation((hsvColor.saturation + 0.3).clamp(0.0, 1.0))
        .withValue((hsvColor.value + 0.2).clamp(0.0, 1.0));
    return enhancedColor.toColor();
  }
}
