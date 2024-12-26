import 'dart:convert';
import 'dart:developer';

class ColorDecoder {
  static Map<String, int>? parseColor(String hexData) {
    try {
      // Se nao tiver '7b' (hex do '{'), já ignoramos
      final jsonStart = hexData.indexOf('7b');
      if (jsonStart == -1) {
        // Retorne null para indicar que não há cor
        log("[ColorDecoder] Não foi encontrado '{' no pacote. Ignorando.");
        return null;
      }

      // Continua a lógica se existe JSON
      final jsonHex = hexData.substring(jsonStart);
      final jsonString = utf8.decode(_decodeHex(jsonHex));
      log("[ColorDecoder] JSON bruto decodificado: $jsonString");

      final Map<String, dynamic> jsonData = json.decode(jsonString);
      log("[ColorDecoder] jsonData: $jsonData");

      final String? payload = jsonData['payload'];
      if (payload == null || payload.length < 14) {
        throw Exception("Payload inválido ou não encontrado.");
      }

      // Pega o prefixo
      final prefix = payload.substring(0, 12);
      log("[ColorDecoder] prefix = $prefix");

      // Extraímos RRGGBB dos caracteres 12..17
      final rgbStartIndex = 12;
      final colorHex = payload.substring(rgbStartIndex, rgbStartIndex + 6);
      log("[ColorDecoder] colorHex = $colorHex");

      // Regras: se prefix == "813324612316", forçamos OFF
      final bool forcedOff = (prefix == "813324612316");
      if (forcedOff) {
        return {"r": 0, "g": 0, "b": 0};
      }

      final r = int.parse(colorHex.substring(0, 2), radix: 16);
      final g = int.parse(colorHex.substring(2, 4), radix: 16);
      final b = int.parse(colorHex.substring(4, 6), radix: 16);
      return {"r": r, "g": g, "b": b};
    } catch (e) {
      log("Erro ao decodificar cor: $e");
      return null;
    }
  }

  static List<int> _decodeHex(String hexStr) {
    final buffer = <int>[];
    for (int i = 0; i < hexStr.length; i += 2) {
      final byte = int.parse(hexStr.substring(i, i + 2), radix: 16);
      buffer.add(byte);
    }
    return buffer;
  }
}
