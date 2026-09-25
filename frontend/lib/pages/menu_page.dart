import 'package:flutter/material.dart';
import 'package:frontend/components/chat_elparche_modal.dart';
import '../components/producto_card.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  void _abrirChatMimos(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ChatElparcheModal(),
    );
  }

  void _mostrarModalDetalle(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detalles del Producto',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'Proximamente disponible con toda la informacion cargada desde el panel administrativo.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 246, 244, 240),
      appBar: AppBar(
        title: const Text(
          'Nuestra Carta',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 191, 40, 93),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 90),
        child: Column(
          children: [
            ProductoCard(
              onVerMas: () => _mostrarModalDetalle(context),
              onComprar: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Funcion de compra disponible proximamente'),
                    backgroundColor: Color(0xFFE91E63),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_chat_menu',
        backgroundColor: const Color.fromARGB(255, 188, 37, 82),
        foregroundColor: Colors.white,
        elevation: 6,
        icon: const Icon(Icons.support_agent_rounded, size: 26),
        label: const Text(
          'Asesor Mimos',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        onPressed: () => _abrirChatMimos(context),
      ),
    );
  }
}