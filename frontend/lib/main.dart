<<<<<<< HEAD
=======
﻿import 'package:flutter/material.dart';

import 'package:elparchee/components/productos.dart';
>>>>>>> 16cdaf6631759378ad4d70b2ced589019b4d0f44
import 'package:elparchee/pantallas/bienvenidos.dart';
import 'package:elparchee/pantallas/inicio.dart';
import 'package:elparchee/pantallas/inicioSesion.dart';
import 'package:elparchee/pantallas/verificacion.dart';

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
      home: const Inicio(),
      routes: {
        '/login': (context) => const Scaffold(body: Iniciosesion()),
        '/verificacion': (context) => const Verification(),
        '/menu': (context) => const Bienvenidos(),
=======
      title: 'El Parche',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8C0E0E)),
      ),
      home: const Inicio(),
      routes: {
        '/login': (context) => const Iniciosesion(),
        '/verificacion': (context) => const Verificacion(),
        '/menu': (context) => const Productos(),
>>>>>>> 16cdaf6631759378ad4d70b2ced589019b4d0f44
        '/bienvenidos': (context) => const Bienvenidos(),
      },
    );
  }
}
