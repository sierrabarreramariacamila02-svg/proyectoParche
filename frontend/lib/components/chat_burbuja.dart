import 'package:flutter/material.dart';

class Mensaje {
  final String texto;
  final bool esUsuario;

  const Mensaje({required this.texto, required this.esUsuario});
}

class ChatBurbuja extends StatefulWidget {
  final Mensaje mensaje;

  const ChatBurbuja({super.key, required this.mensaje});

  @override
  State<ChatBurbuja> createState() => _ChatBurbujaState();
}

class _ChatBurbujaState extends State<ChatBurbuja> {
  @override
  Widget build(BuildContext context) {
    final esUsuario = widget.mensaje.esUsuario;
    return Align(
      alignment: esUsuario ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: esUsuario ? Colors.orange : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(esUsuario ? 16 : 0),
            bottomRight: Radius.circular(esUsuario ? 0 : 16),
          ),
        ),
        child: Text(
          widget.mensaje.texto,
          style: TextStyle(
            color: esUsuario ? Colors.white : Colors.black87,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}