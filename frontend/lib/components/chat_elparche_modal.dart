import 'package:elparchee/components/chat_burbuja.dart';
import 'package:elparchee/components/chat_header.dart';
import 'package:elparchee/components/chat_input_field.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void mostrarChatElParche(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const ChatElParcheModal(),
  );
}

class ChatElParcheModal extends StatefulWidget {
  const ChatElParcheModal({super.key});

  @override
  State<ChatElParcheModal> createState() => _ChatElParcheModalState();
}

class _ChatElParcheModalState extends State<ChatElParcheModal> {
  final TextEditingController _controlador = TextEditingController();
  final ScrollController _scroll = ScrollController();
  bool _cargando = false;

  // Ajusta la IP según tu entorno (10.0.2.2 para emulador Android)
  final String _apiUrl = "http://10.0.2.2:3000/api/chatBot";
  final String _sesionId = "sesion_usuario_123";

  final List<Mensaje> _mensajes = [
    const Mensaje(
      texto: '¡Hola! Soy el asistente de El Parche. ¿En qué te puedo ayudar hoy?',
      esUsuario: false,
    ),
  ];

  @override
  void dispose() {
    _controlador.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final texto = _controlador.text.trim();
    if (texto.isEmpty || _cargando) return;

    setState(() {
      _mensajes.add(Mensaje(texto: texto, esUsuario: true));
      _cargando = true;
    });

    _controlador.clear();
    _bajar();

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': texto,
          'sesionId': _sesionId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final respuestaIA = data['response'] ?? data['reply'] ?? data['message'] ?? 'Sin respuesta';

        setState(() {
          _mensajes.add(Mensaje(texto: respuestaIA, esUsuario: false));
        });
      } else {
        setState(() {
          _mensajes.add(const Mensaje(
            texto: 'Lo siento, hubo un error en el servidor.',
            esUsuario: false,
          ));
        });
      }
    } catch (e) {
      setState(() {
        _mensajes.add(const Mensaje(
          texto: 'Error de conexión con el backend.',
          esUsuario: false,
        ));
      });
    } finally {
      setState(() {
        _cargando = false;
      });
      _bajar();
    }
  }

  void _bajar() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color fondoCrema = Color(0xFFFDFBF7); 

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.82,
        decoration: const BoxDecoration(
          color: fondoCrema,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // Aquí integramณ์ tu componente ChatHeader respetando tu onCerrar
            ChatHeader(
              onCerrar: () => Navigator.pop(context),
            ),
            // Cuerpo del chat con los mensajes
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                itemCount: _mensajes.length,
                itemBuilder: (_, index) => ChatBurbuja(mensaje: _mensajes[index]),
              ),
            ),
            if (_cargando)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange),
                ),
              ),
            // Tu componente de input de texto inferior
            ChatInputField(
              controlador: _controlador,
              onEnviar: _enviar,
            ),
          ],
        ),
      ),
    );
  }
}