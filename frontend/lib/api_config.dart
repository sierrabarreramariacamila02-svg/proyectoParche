import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  static const bool useRemote = true;

  static const String _remoteUrl = 'https://el-parche.onrender.com/api';
  static const int _port = 3000;
  static const String _lanIp = '192.168.1.160';

  static String get baseUrl {
    if (useRemote) {
      return _remoteUrl;
    }

    if (kIsWeb) {
      return 'http://localhost:$_port/api';
    }

    if (Platform.isAndroid) {
      return 'http://$_lanIp:$_port/api';
    }

    if (Platform.isIOS) {
      return 'http://localhost:$_port/api';
    }

    return 'http://localhost:$_port/api';
  }

  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'accept': 'application/json',
  };
}