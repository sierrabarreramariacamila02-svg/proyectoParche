import 'package:elparchee/components/chat_burbuja.dart';
import 'package:elparchee/components/chat_header.dart';
import 'package:elparchee/components/chat_input_field.dart';
import 'package:elparchee/models/producto_model.dart';
import 'package:elparchee/services/cart_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../api_config.dart';

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

  final String _sesionId = 'parche_${DateTime.now().millisecondsSinceEpoch}';

  final List<Mensaje> _mensajes = [
    const Mensaje(
      texto:
          '¡Hola! Soy el asistente de El Parche. ¿En qué te puedo ayudar hoy?',
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

    final historial = _mensajes
        .map(
          (mensaje) => {
            'role': mensaje.esUsuario ? 'user' : 'assistant',
            'content': mensaje.texto,
          },
        )
        .toList();

    setState(() {
      _mensajes.add(Mensaje(texto: texto, esUsuario: true));
      _cargando = true;
    });

    _controlador.clear();
    _bajar();

    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/chatbot'),
            headers: ApiConfig.headers,
            body: jsonEncode({
              'message': texto,
              'sesionId': _sesionId,
              'historial': historial,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is! Map<String, dynamic>) {
          throw const FormatException('Respuesta inválida del chatbot.');
        }
        final sugeridos = <ProductoModel>[];
        final productos = decoded['productosSugeridos'];
        if (productos is List) {
          for (final producto in productos) {
            if (producto is Map) {
              sugeridos.add(
                ProductoModel.fromJson(Map<String, dynamic>.from(producto)),
              );
            }
          }
        }
        final respuestaIA =
            decoded['respuesta'] ??
            decoded['response'] ??
            decoded['reply'] ??
            decoded['message'] ??
            'Sin respuesta';

        if (!mounted) return;
        setState(() {
          _mensajes.add(
            Mensaje(
              texto: respuestaIA.toString(),
              esUsuario: false,
              productos: sugeridos,
            ),
          );
        });
      } else {
        if (!mounted) return;
        setState(() {
          _mensajes.add(
            const Mensaje(
              texto: 'Lo siento, hubo un error en el servidor.',
              esUsuario: false,
            ),
          );
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _mensajes.add(
          const Mensaje(
            texto: 'Error de conexión con el backend.',
            esUsuario: false,
          ),
        );
      });
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
        _bajar();
      }
    }
  }

  void _agregarAlCarrito(ProductoModel producto) {
    CartService.instance.add(producto);
    setState(() {
      _mensajes.add(
        Mensaje(
          texto:
              'Agregué ${producto.nombre} al carrito. Puedes revisar tu pedido y ajustar la cantidad allí.',
          esUsuario: false,
        ),
      );
    });
    _bajar();
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
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
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
            ChatHeader(onCerrar: () => Navigator.pop(context)),
            // Cuerpo del chat con los mensajes
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
                itemCount: _mensajes.length,
                itemBuilder: (_, index) => ChatBurbuja(
                  mensaje: _mensajes[index],
                  onAgregarProducto: _agregarAlCarrito,
                ),
              ),
            ),
            if (_cargando)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.orange,
                  ),
                ),
              ),
            // Tu componente de input de texto inferior
            ChatInputField(controlador: _controlador, onEnviar: _enviar),
          ],
        ),
      ),
    );
  }
}
