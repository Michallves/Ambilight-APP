import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';

/// Biblioteca nativa do Windows
final gdi32 = DynamicLibrary.open('gdi32.dll');
final user32 = DynamicLibrary.open('user32.dll');

class GDICapture {
  late final Pointer<Void> _hdcScreen;
  late final Pointer<Void> _hdcMemory;
  Pointer<Void> _bitmap = nullptr;
  Pointer<Void> _oldBitmap = nullptr;

  GDICapture() {
    _hdcScreen = user32.lookupFunction<Pointer<Void> Function(Pointer<Void>),
        Pointer<Void> Function(Pointer<Void>)>('GetDC')(nullptr);
    _hdcMemory = gdi32.lookupFunction<
        Pointer<Void> Function(Pointer<Void>),
        Pointer<Void> Function(
            Pointer<Void>)>('CreateCompatibleDC')(_hdcScreen);

    if (_hdcScreen == nullptr || _hdcMemory == nullptr) {
      throw Exception('Falha ao inicializar HDCs para captura de tela.');
    }
  }

  Uint8List? captureScreen({int width = 1920, int height = 1080}) {
    // Configurações de captura
    final bitmapInfo = calloc<BITMAPINFO>();
    bitmapInfo.ref.bmiHeader.biSize = sizeOf<BITMAPINFOHEADER>();
    bitmapInfo.ref.bmiHeader.biWidth = width;
    bitmapInfo.ref.bmiHeader.biHeight = -height; // Valores negativos para flip
    bitmapInfo.ref.bmiHeader.biPlanes = 1;
    bitmapInfo.ref.bmiHeader.biBitCount = 32; // Formato RGB 32 bits
    bitmapInfo.ref.bmiHeader.biCompression = 0;

    final buffer = calloc<Uint8>(width * height * 4); // RGBA buffer

    try {
      // Libera o bitmap atual, se existir
      if (_bitmap != nullptr) {
        gdi32.lookupFunction<Pointer<Void> Function(Pointer<Void>),
            Pointer<Void> Function(Pointer<Void>)>('DeleteObject')(_bitmap);
        _bitmap = nullptr;
      }

      // Cria o bitmap
      _bitmap = gdi32.lookupFunction<
          Pointer<Void> Function(Pointer<Void>, Int32, Int32),
          Pointer<Void> Function(Pointer<Void>, int,
              int)>('CreateCompatibleBitmap')(_hdcScreen, width, height);

      if (_bitmap == nullptr) {
        throw Exception('Falha ao criar bitmap.');
      }

      _oldBitmap = gdi32.lookupFunction<
          Pointer<Void> Function(Pointer<Void>, Pointer<Void>),
          Pointer<Void> Function(Pointer<Void>,
              Pointer<Void>)>('SelectObject')(_hdcMemory, _bitmap);

      // Copia os dados da tela para o bitmap
      final bitBltResult = gdi32.lookupFunction<
              Int32 Function(Pointer<Void>, Int32, Int32, Int32, Int32,
                  Pointer<Void>, Int32, Int32, Uint32),
              int Function(Pointer<Void>, int, int, int, int, Pointer<Void>,
                  int, int, int)>('BitBlt')(
          _hdcMemory, 0, 0, width, height, _hdcScreen, 0, 0, 0x00CC0020);

      if (bitBltResult == 0) {
        throw Exception('Falha ao copiar tela para o bitmap.');
      }

      // Recupera os dados do bitmap
      final getDIBitsResult = gdi32.lookupFunction<
              Int32 Function(Pointer<Void>, Pointer<Void>, Uint32, Uint32,
                  Pointer<Void>, Pointer<BITMAPINFO>, Uint32),
              int Function(Pointer<Void>, Pointer<Void>, int, int,
                  Pointer<Void>, Pointer<BITMAPINFO>, int)>('GetDIBits')(
          _hdcMemory, _bitmap, 0, height, buffer.cast<Void>(), bitmapInfo, 0);

      if (getDIBitsResult == 0) {
        throw Exception('Falha ao recuperar bits do bitmap.');
      }

      return Uint8List.fromList(buffer.asTypedList(width * height * 4));
    } finally {
      calloc.free(buffer);
      calloc.free(bitmapInfo);
    }
  }

  void dispose() {
    if (_bitmap != nullptr) {
      gdi32.lookupFunction<Int32 Function(Pointer<Void>),
          int Function(Pointer<Void>)>('DeleteObject')(_bitmap);
    }

    if (_oldBitmap != nullptr) {
      gdi32.lookupFunction<Int32 Function(Pointer<Void>),
          int Function(Pointer<Void>)>('DeleteObject')(_oldBitmap);
    }

    gdi32.lookupFunction<Int32 Function(Pointer<Void>),
        int Function(Pointer<Void>)>('DeleteDC')(_hdcMemory);
    user32.lookupFunction<Int32 Function(Pointer<Void>),
        int Function(Pointer<Void>)>('ReleaseDC')(_hdcScreen);
  }
}

/// Estrutura BITMAPINFO
final class BITMAPINFO extends Struct {
  external BITMAPINFOHEADER bmiHeader;
  @Array(256)
  external Array<Uint32> bmiColors;
}

/// Estrutura BITMAPINFOHEADER
final class BITMAPINFOHEADER extends Struct {
  @Uint32()
  external int biSize;
  @Int32()
  external int biWidth;
  @Int32()
  external int biHeight;
  @Uint16()
  external int biPlanes;
  @Uint16()
  external int biBitCount;
  @Uint32()
  external int biCompression;
  @Uint32()
  external int biSizeImage;
  @Int32()
  external int biXPelsPerMeter;
  @Int32()
  external int biYPelsPerMeter;
  @Uint32()
  external int biClrUsed;
  @Uint32()
  external int biClrImportant;
}
