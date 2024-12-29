import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:math';

class ImageProcessor {
  /// Retorna a cor predominante para a fita de LED com base na imagem em HSV.
  HSVColor calculateAmbientColor(Uint8List imageData, int width, int height) {
    // Resolução reduzida para processamento eficiente
    final int reducedWidth = 128;
    final int reducedHeight = 128;

    // Multiplicadores de percepção e reforço
    const double redBoostFactor = 1.5;
    const double greenBoostFactor = 1.0;
    const double blueBoostFactor = 1.0;
    const double saturationBoostFactor = 1.2;
    const double edgeWeightFactor = 1.5; // Peso extra para as bordas

    // Para acumular as cores
    double totalR = 0;
    double totalG = 0;
    double totalB = 0;
    double totalWeight = 0;

    // Escala para mapear a imagem original para a reduzida
    final double scaleX = width / reducedWidth;
    final double scaleY = height / reducedHeight;

    // Coordenadas do centro da tela e raio para ignorar o centro
    final centerX = reducedWidth / 2;
    final centerY = reducedHeight / 2;
    final double ignoreRadius =
        reducedWidth * 0.25; // Raio para ignorar o centro

    for (int y = 0; y < reducedHeight; y++) {
      for (int x = 0; x < reducedWidth; x++) {
        // Pega o índice aproximado do pixel original
        final int originalX = (x * scaleX).toInt();
        final int originalY = (y * scaleY).toInt();
        final int pixelIndex = (originalY * width + originalX) * 4;

        // Calcula a distância do pixel ao centro
        final double distanceToCenter =
            sqrt(pow(x - centerX, 2) + pow(y - centerY, 2));

        // Ignora pixels dentro do raio definido
        if (distanceToCenter < ignoreRadius) {
          continue;
        }

        // Extrai as cores no formato BGRA
        final int b = imageData[pixelIndex];
        final int g = imageData[pixelIndex + 1];
        final int r = imageData[pixelIndex + 2];

        // Calcula o brilho percebido (luminância) ajustado
        final double luminance = 0.3 * r + 0.59 * g + 0.11 * b;

        // Calcula o peso para as bordas
        final double maxDistance = sqrt(pow(centerX, 2) + pow(centerY, 2));
        final double edgeWeight =
            1 + (edgeWeightFactor * (distanceToCenter / maxDistance));

        // Acumula a cor ponderada pela luminância e peso das bordas
        totalR += (r * redBoostFactor) * luminance * edgeWeight;
        totalG += (g * greenBoostFactor) * luminance * edgeWeight;
        totalB += (b * blueBoostFactor) * luminance * edgeWeight;
        totalWeight += luminance * edgeWeight;
      }
    }

    // Calcula a média ponderada
    int finalR = (totalR / totalWeight).clamp(0, 255).toInt();
    int finalG = (totalG / totalWeight).clamp(0, 255).toInt();
    int finalB = (totalB / totalWeight).clamp(0, 255).toInt();

    // Converte para HSV
    HSVColor hsvColor = RGBtoHSV.convert(finalR, finalG, finalB);

    // Aumenta a saturação para realçar as cores
    hsvColor = hsvColor.withSaturation(
        (hsvColor.saturation * saturationBoostFactor).clamp(0.0, 1.0));

    return hsvColor;
  }
}

class RGBtoHSV {
  /// Converte RGB para HSV.
  static HSVColor convert(int r, int g, int b) {
    // Normaliza RGB para [0, 1]
    final double rPrime = r / 255.0;
    final double gPrime = g / 255.0;
    final double bPrime = b / 255.0;

    // Calcula Cmax, Cmin e Delta
    final double cMax = max(rPrime, max(gPrime, bPrime));
    final double cMin = min(rPrime, min(gPrime, bPrime));
    final double delta = cMax - cMin;

    // Calcula Hue (H)
    double hue;
    if (delta == 0) {
      hue = 0;
    } else if (cMax == rPrime) {
      hue = 60 * (((gPrime - bPrime) / delta) % 6);
    } else if (cMax == gPrime) {
      hue = 60 * (((bPrime - rPrime) / delta) + 2);
    } else {
      hue = 60 * (((rPrime - gPrime) / delta) + 4);
    }
    if (hue < 0) {
      hue += 360; // Garantir que o Hue esteja entre 0-360
    }

    // Calcula Saturação (S)
    double saturation = (cMax == 0) ? 0 : (delta / cMax);

    // Calcula Valor (V)
    double value = cMax;

    // Retorna HSVColor
    return HSVColor.fromAHSV(1.0, hue, saturation, value);
  }
}
