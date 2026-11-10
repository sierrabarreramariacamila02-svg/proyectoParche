import 'package:flutter/material.dart';

class Mensaje {
  final String texto;
  final bool esUsuario;

  const Mensaje({required this.texto, required this.esUsuario});
}

class ChatBurbuja extends StatelessWidget {
  final Mensaje mensaje;

  const ChatBurbuja({super.key, required this.mensaje});

  @override
  Widget build(BuildContext context) {
    final esUsuario = mensaje.esUsuario;
    
    return Align(
      alignment: esUsuario ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          // Color naranja para el usuario y un tono gris/crema suave para la IA
          color: esUsuario ? const Color(0xFFE59866) : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(esUsuario ? 16 : 0),
            bottomRight: Radius.circular(esUsuario ? 0 : 16),
          ),
        ),
        child: Text(
          mensaje.texto,
          style: TextStyle(
            color: esUsuario ? Colors.white : Colors.black87,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}