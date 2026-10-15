import 'package:elparchee/components/productos.dart';
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8C0E0E)),
      ),
      home: const Inicio(),
      routes: {
        '/login': (context) => const Iniciosesion(),
        '/verificacion': (context) => const Verificacion(),
        '/menu': (context) => const Productos(), 
        '/bienvenidos': (context) => const Bienvenidos(),
        // Rutas añadidas para que coincidan con las opciones de tu DrawerContent:
        '/inicio': (context) => const Inicio(),
        '/platos': (context) => const Productos(), // O cámbialo por su pantalla respectiva cuando la crees
        '/carrito': (context) => const Productos(),
        '/pedidos': (context) => const Productos(),
        '/domicilios': (context) => const Productos(),
        '/favoritos': (context) => const Productos(),
        '/promociones': (context) => const Productos(),
        '/perfil': (context) => const Productos(),
        '/administracion': (context) => const Productos(),
 
      },
    );
  }
}
