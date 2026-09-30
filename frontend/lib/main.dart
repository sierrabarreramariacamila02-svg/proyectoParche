import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'pages/menu_page.dart';
=======
import 'package:parche/components/inicio.dart';
import 'package:parche/components/inicioSesion.dart';
import 'package:parche/components/verificacion.dart';
>>>>>>> 0316c6c (Actualización de código y nuevos assets)

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
<<<<<<< HEAD
      title: 'El parche',
      home: MenuPage(),
=======
      home: Scaffold(body: Inicio()),
      routes: {'/login': (context) => const Scaffold(body: Iniciosesion()),
      '/verificacion': (context) => const Verification()},
>>>>>>> 0316c6c (Actualización de código y nuevos assets)
    );
  }
}