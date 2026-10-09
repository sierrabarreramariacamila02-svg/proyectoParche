import 'package:elparchee/pantallas/bienvenidos.dart';
import 'package:elparchee/pantallas/inicio.dart';
import 'package:elparchee/pantallas/inicioSesion.dart';
import 'package:elparchee/pantallas/verificacion.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'El parche',
      home: const Inicio(),
      routes: {
        '/login': (context) => const Scaffold(body: Iniciosesion()),
        '/verificacion': (context) => const Verification(),
        '/menu': (context) => const Bienvenidos(),
        '/bienvenidos': (context) => const Bienvenidos(),
      },
    );
  }
}
