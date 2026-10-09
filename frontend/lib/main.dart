<<<<<<< Updated upstream
<<<<<<< Updated upstream
import 'package:elparchee/pantallas/bienvenidos.dart';
=======
import 'package:elparchee/components/chat_elparche_modal.dart';
>>>>>>> Stashed changes
import 'package:flutter/material.dart';
 
=======
import 'package:elparchee/components/productos.dart';
import 'package:elparchee/pantallas/bienvenidos.dart';
import 'package:elparchee/pantallas/inicio.dart';
import 'package:elparchee/pantallas/inicioSesion.dart';
import 'package:elparchee/pantallas/verificacion.dart';
import 'package:flutter/material.dart';

>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
<<<<<<< Updated upstream
      home: Bienvenidos(),
=======
      home: ChatElparcheModal(),
>>>>>>> Stashed changes
=======
      home: const Inicio(),
      routes: {
        '/login': (context) => const Scaffold(body: Iniciosesion()),
        '/verificacion': (context) => const Verification(),
        '/menu': (context) => const Productos(),
        '/bienvenidos': (context) => const Bienvenidos(),
      },
>>>>>>> Stashed changes
    );
  }
}
