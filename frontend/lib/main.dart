import 'package:elparchee/pantallas/inicio.dart';
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
      title: 'El Parche',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8C0E0E)),
      ),
      home: const Inicio(), 

      routes: {
        '/verificacion': (context) => const Verificacion(), 
      },
    );
  }
}
