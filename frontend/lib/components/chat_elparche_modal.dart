import 'package:flutter/material.dart';

import 'package:elparchee/components/chat_burbuja.dart';
import 'package:elparchee/components/chat_header.dart';
import 'package:elparchee/components/chat_input_field.dart';
import 'package:elparchee/services/chatelparcheservice.dart';

class ChatElparcheModal extends StatefulWidget {
  const ChatElparcheModal({super.key});

  @override
  State<ChatElparcheModal> createState() => _ChatMimosModalState();
}

class _ChatMimosModalState extends State<ChatElparcheModal> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _mensajes = [
    {
      'role': 'bot',
      'text': '¡Hola! Bienvenido a El Parche 🍔 ¿Qué se te antoja comer o pedir hoy?',
    },
  ];
  bool _cargando = false;

  void _enviarMensaje() async {
    final texto = _controller.text.trim();
    if (texto.isEmpty || _cargando) return;

    _controller.clear();
    setState(() {
      _mensajes.add({'role': 'user', 'text': texto});
      _cargando = true;
    });
    _scrollHaciaAbajo();

    final respuesta = await ChatParcheService.enviarMensaje(texto);

    if (mounted) {
      setState(() {
        _mensajes.add({'role': 'bot', 'text': respuesta});
        _cargando = false;
      });
      _scrollHaciaAbajo();
    }
  }

  void _scrollHaciaAbajo() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Color(0xFFFBF1DC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: Column(
          children: [
            const ChatHeader(),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
                itemCount: _mensajes.length,
                itemBuilder: (context, index) {
                  final item = _mensajes[index];
                  return ChatBurbuja(
                    texto: item['text']!,
                    esUsuario: item['role'] == 'user',
                  );
                },
              ),
            ),
            if (_cargando)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF6E3),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFFE8963F).withOpacity(0.35),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF8E1B10),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'El asesor esta respondiendo...',
                          style: TextStyle(
                            color: Color(0xFF8E5A33),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ChatInputField(
              controller: _controller,
              cargando: _cargando,
              onEnviar: _enviarMensaje,
            ),
          ],
        ),
      ),
    );
  }
}