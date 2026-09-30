import 'package:elparchee/components/chat_elparche_modal.dart';
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
      home: ChatElparcheModal(),
    );
  }
}