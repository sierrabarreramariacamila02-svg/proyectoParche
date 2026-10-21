import 'package:elparchee/components/productos.dart';
import 'package:flutter/material.dart';
import 'package:elparchee/app_colors.dart';
import 'package:elparchee/pantallas/buscar.dart';
import 'package:elparchee/pantallas/perfil.dart';

class Pedidos extends StatelessWidget {
  const Pedidos({super.key});

  @override
  Widget build(BuildContext context) {
    const rojo = AppColors.barraHome;
    const naranja = AppColors.buttonOrange;
    const crema = AppColors.background;

    return Scaffold(
      backgroundColor: crema,
      appBar: AppBar(
        backgroundColor: rojo,
        title: const Text('Pedidos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: const [Icon(Icons.notifications_none, color: Colors.white), SizedBox(width: 16)],
      ),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 25,
                  backgroundColor: Color(0xFFF3C082),
                  child: Icon(Icons.check, color: rojo, size: 30),
                ),
                const SizedBox(height: 10),
                const Text("¡Pedido confirmado!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: rojo)),
                const Text("Tu pedido #1234 ha sido recibido\ny está en proceso.", textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFF2EAD8), borderRadius: BorderRadius.circular(10)),
                  child: const Row(
                    children: [
                      Icon(Icons.delivery_dining, color: naranja, size: 30),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Tiempo estimado de entrega", style: TextStyle(fontSize: 10, color: Colors.grey)),
                          Text("30 - 45 min", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                _pasoEstado("Pedido recibido", "12:10 p.m.", true),
                _pasoEstado("En preparación", "12:18 p.m.", true),
                _pasoEstado("En camino", "", false),
                _pasoEstado("Entregado", "", false),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: naranja,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 42),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text("Ver seguimiento", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          const Text("Resumen del pedido", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
            child: Row(
              children: [
                Container(width: 50, height: 50, decoration: BoxDecoration(color: const Color(0xFFF2EAD8), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.fastfood, color: naranja)),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Combo Familiar", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      Text("\$74.000", style: TextStyle(color: rojo, fontWeight: FontWeight.bold, fontSize: 11)),
                    ],
                  ),
                ),
                const Text("x1", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _pasoEstado(String titulo, String hora, bool completado) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: completado ? AppColors.barraHome : Colors.grey.shade300,
              ),
              child: Icon(completado ? Icons.check : Icons.circle, size: 12, color: Colors.white),
            ),
            Container(width: 2, height: 25, color: completado ? AppColors.barraHome : Colors.grey.shade300),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // <--- CORREGIDO AQUÍ
            children: [
              Text(titulo, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: completado ? Colors.black : Colors.grey)),
              if (hora.isNotEmpty) Text(hora, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      color: AppColors.barraInferior,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 8, left: 16, right: 16),
          child: SizedBox(
            height: 30,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(icon: const Icon(Icons.home_outlined, color: Colors.brown), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Productos()))),
                    IconButton(icon: const Icon(Icons.search, color: Colors.brown), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Buscar()))),
                    const SizedBox(width: 50),
                    IconButton(icon: const Icon(Icons.receipt_long, color: AppColors.barraHome), onPressed: () {}),
                    IconButton(icon: const Icon(Icons.person_outline, color: Colors.brown), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Perfil()))),
                  ],
                ),
                Positioned(
                  top: -24,
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.buttonOrange,
                    child: IconButton(icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 28), onPressed: () {}),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}