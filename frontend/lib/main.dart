<<<<<<< Updated upstream
import 'package:elparchee/pantallas/bienvenidos.dart';
=======
import 'package:elparchee/components/chat_elparche_modal.dart';
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
      home: Bienvenidos(),
=======
      home: ChatElparcheModal(),
>>>>>>> Stashed changes
    );
  }
}
