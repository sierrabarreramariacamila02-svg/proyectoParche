import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
class ApiConfig {
  static const bool useRemote = true; // Cambiado a false para usar tu servidor local por IP

static const String _remoteUrl = 'https://el-parche.onrender.com/api';
  static const int _port = 3000; // Puerto del servidor local
  static const String? _lanIp = '192.168.1.160'; // Tu IP local de Wi-Fi

  static String get baseUrl {
    if (useRemote) {
      return _remoteUrl;
    }
    if (kIsWeb) {
      return 'http://localhost:$_port/api';
    }
    if (_lanIp != null) {
      return 'http://$_lanIp:$_port/api';
    }
    if (Platform.isAndroid) {
<<<<<<< HEAD
      // Usando tu IP Local actualizada para el celular físico
      return 'http://192.168.1.174:3000/api';
    } else if (Platform.isIOS) {
      // Simulador de iOS
      return 'http://localhost:3000/api';
=======
      return 'http://10.0.2.2:$_port/api';
>>>>>>> 48bdf18621d817100a66b4507635d1a4aff118e9
    }
    return 'http://localhost:$_port/api';
  }

  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'accept': 'application/json',
  };
}