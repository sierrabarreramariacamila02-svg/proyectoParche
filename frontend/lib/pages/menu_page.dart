import 'package:elparchee/components/chat_elparche_modal.dart';
import 'package:flutter/material.dart';
import 'package:elparchee/app_colors.dart';


class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  void _abrirChatMimos(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ChatElParcheModal(),
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
        backgroundColor: AppColors.barraHome,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 90,
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => _mostrarModalDetalle(context),
              child: const Text('Ver más'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Funcion de compra disponible proximamente'),
                    backgroundColor: AppColors.barraHome,
                  ),
                );
              },
              child: const Text('Comprar'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_chat_menu',
        backgroundColor: AppColors.barraHome,
        foregroundColor: Colors.white,
        elevation: 6,
        icon: const Icon(Icons.support_agent_rounded, size: 26),
        label: const Text(
          'Asesor El Parche',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        onPressed: () => _abrirChatMimos(context),
      ),
    );
  }
}

class ProductoCard extends StatelessWidget {
  final VoidCallback onVerMas;
  final VoidCallback onComprar;

  const ProductoCard({
    super.key,
    required this.onVerMas,
    required this.onComprar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 180,
            width: double.infinity,
            color: const Color(0xFFF9D9C7),
            child: const Center(
              child: Icon(
                Icons.fastfood_rounded,
                size: 84,
                color: AppColors.barraHome,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Combo El Parche',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Hamburguesa, papas + bebida personalizable.',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 14),
                const Text(
                  '32.000 COP',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.background,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onVerMas,
                        child: const Text('Ver más'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onComprar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.background,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Comprar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
