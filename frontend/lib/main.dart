import 'package:flutter/material.dart';
import 'package:elparchee/pantallas/inicio.dart';
 
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
      home: Inicio(),
    );
  }
}