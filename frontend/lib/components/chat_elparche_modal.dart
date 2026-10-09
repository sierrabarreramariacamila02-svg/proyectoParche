import 'package:elparchee/components/chat_burbuja.dart';
import 'package:elparchee/components/chat_header.dart';
import 'package:elparchee/components/chat_input_field.dart';
import 'package:flutter/material.dart';

class _ProductoInfo {
  final String nombre;
  final String descripcion;
  final int precio;

  const _ProductoInfo({
    required this.nombre,
    required this.descripcion,
    required this.precio,
  });
}

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
  final _controlador = TextEditingController();
  final _scroll = ScrollController();
  final List<_ProductoInfo> _productos = const [
    _ProductoInfo(
      nombre: 'Hamburguesa',
      descripcion: 'Hamburguesa artesanal con queso y salsa especial.',
      precio: 18000,
    ),
    _ProductoInfo(
      nombre: 'Perro caliente',
      descripcion: 'Perro caliente con papa, salsa y queso.',
      precio: 14000,
    ),
    _ProductoInfo(
      nombre: 'Salchipapa',
      descripcion: 'Salchipapa con queso, salsas y tocineta.',
      precio: 16000,
    ),
    _ProductoInfo(
      nombre: 'Bebida',
      descripcion: 'Bebida fría de sabores para acompañar.',
      precio: 5000,
    ),
  ];
  final List<Mensaje> _mensajes = const [
    Mensaje(
      texto: '¡Hola! Soy el asistente de El Parche. Pregúntame por productos, precios u horarios.',
      esUsuario: false,
    ),
  ];

  @override
  void dispose() {
    _controlador.dispose();
    _scroll.dispose();
    super.dispose();
  }

  String _responder(String entrada) {
    final t = entrada.toLowerCase();

    for (final p in _productos) {
      if (t.contains(p.nombre.toLowerCase())) {
        return '${p.nombre}: ${p.descripcion}. Precio: \$${p.precio}.';
      }
    }
    if (t.contains('hola') || t.contains('buenas')) {
      return '¡Hola! ¿En qué te puedo ayudar?';
    }
    if (t.contains('producto') || t.contains('menu') || t.contains('carta')) {
      return 'Tenemos:\n${_productos.map((p) => '• ${p.nombre}').join('\n')}';
    }
    if (t.contains('precio') || t.contains('cuesta') || t.contains('valor')) {
      return _productos.map((p) => '${p.nombre}: \$${p.precio}').join('\n');
    }
    if (t.contains('horario') || t.contains('abierto')) {
      return 'Atendemos de lunes a sábado, de 8:00 a.m. a 8:00 p.m.';
    }
    if (t.contains('gracias')) return '¡Con gusto! 😊';
    return 'No te entendí bien. Prueba con "productos", "precios" u "horario".';
  }

  void _enviar() {
    final texto = _controlador.text.trim();
    if (texto.isEmpty) return;

    setState(() => _mensajes.add(Mensaje(texto: texto, esUsuario: true)));
    _controlador.clear();
    _bajar();

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _mensajes
          .add(Mensaje(texto: _responder(texto), esUsuario: false)));
      _bajar();
    });
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
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            ChatHeader(onCerrar: () => Navigator.pop(context)),
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _mensajes.length,
                itemBuilder: (_, i) => ChatBurbuja(mensaje: _mensajes[i]),
              ),
            ),
            ChatInputField(controlador: _controlador, onEnviar: _enviar),
          ],
        ),
      ),
    );
  }
}