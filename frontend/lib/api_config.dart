import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  static String get baseUrl {
    // 1. Evaluar Web primero para evitar que Platform.isX genere un error en JS
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }

    // 2. Evaluaciones para dispositivos móviles / desktop
    if (Platform.isAndroid) {
      // Emulador de Android
      return 'http://10.0.2.2:3000/api';
    } else if (Platform.isIOS) {
      // Simulador de iOS
      return 'http://localhost:3000/api';
    }

    // Fallback para macOS, Windows, Linux, etc.
    return 'http://localhost:3000/api';
  }

  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}