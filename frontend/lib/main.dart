<<<<<<< HEAD
<<<<<<< HEAD
=======
<<<<<<< Updated upstream
<<<<<<< Updated upstream
import 'package:elparchee/pantallas/bienvenidos.dart';
=======
>>>>>>> paola
import 'package:elparchee/components/chat_elparche_modal.dart';
>>>>>>> Stashed changes
import 'package:flutter/material.dart';
 
<<<<<<< HEAD
<<<<<<< HEAD
=======
import 'package:elparchee/components/productos.dart';
import 'package:flutter/material.dart';
import 'package:elparchee/components/inicio.dart';
import 'package:elparchee/components/inicioSesion.dart';
import 'package:elparchee/components/verificacion.dart';
import 'package:elparchee/components/productos.dart';

>>>>>>> 3da53de1750715ee79dc66c1d9585220dbbfcba7
=======
>>>>>>> paola
=======
=======
import 'package:elparchee/components/productos.dart';
import 'package:elparchee/pantallas/bienvenidos.dart';
import 'package:elparchee/pantallas/inicio.dart';
import 'package:elparchee/pantallas/inicioSesion.dart';
import 'package:elparchee/pantallas/verificacion.dart';
import 'package:flutter/material.dart';

>>>>>>> Stashed changes
>>>>>>> paola
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
<<<<<<< HEAD
<<<<<<< HEAD
      home: ChatElparcheModal(),
=======
      home: const Inicio(),
      routes: {
        '/login': (context) => const Scaffold(body: Iniciosesion()),
        '/verificacion': (context) => const Verification(),
        '/menu': (context) => const Productos(),
      },
>>>>>>> 3da53de1750715ee79dc66c1d9585220dbbfcba7
=======
<<<<<<< Updated upstream
<<<<<<< Updated upstream
      home: Bienvenidos(),
=======
      home: ChatElparcheModal(),
>>>>>>> Stashed changes
<<<<<<< HEAD
>>>>>>> paola
=======
=======
      home: const Inicio(),
      routes: {
        '/login': (context) => const Scaffold(body: Iniciosesion()),
        '/verificacion': (context) => const Verification(),
        '/menu': (context) => const Productos(),
        '/bienvenidos': (context) => const Bienvenidos(),
      },
>>>>>>> Stashed changes
>>>>>>> paola
    );
  }
}
