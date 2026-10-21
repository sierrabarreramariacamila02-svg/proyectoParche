import 'package:flutter/material.dart';
import 'package:elparchee/app_colors.dart';
import 'package:elparchee/pantallas/pedidos.dart';
import 'package:elparchee/components/productos.dart';
import 'package:elparchee/pantallas/buscar.dart';
import 'package:elparchee/pantallas/perfil.dart';

class Domicilio extends StatelessWidget {
  const Domicilio({super.key});

  @override
  Widget build(BuildContext context) {
    const rojo = AppColors.barraHome;
    const naranja = AppColors.buttonOrange;
    const crema = AppColors.background;

    return Scaffold(
      backgroundColor: crema,
      appBar: AppBar(
        backgroundColor: rojo,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Domicilio', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: const [Icon(Icons.notifications_none, color: Colors.white), SizedBox(width: 16)],
      ),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.location_on, color: naranja),
                    SizedBox(width: 8),
                    Text("Datos de entrega", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                const Text("Confirma tu dirección para continuar con el pedido.", style: TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: const Color(0xFFF2EAD8), borderRadius: BorderRadius.circular(20)),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: 'Busca tu dirección...',
                      icon: Icon(Icons.search, color: naranja, size: 20),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(color: const Color(0xFFF3C082), borderRadius: BorderRadius.circular(20)),
                  child: const Center(
                    child: Text("Elegir ubicación en el mapa", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87)),
                  ),
                ),
                const SizedBox(height: 10),
                // Contenedor simulando mapa estático
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey.shade300,
                    image: const DecorationImage(
                      image: NetworkImage('https://maps.googleapis.com/maps/api/staticmap?center=4.5,-74.2&zoom=13&size=400x200&sensor=false'), // Placeholder estático simulado de mapa
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: const Center(child: Icon(Icons.location_pin, color: Colors.red, size: 40)),
                ),
                const SizedBox(height: 10),
                _campoInfo(Icons.home, "Dirección", "Calle 10 #12-34"),
                const Divider(height: 15),
                _campoInfo(Icons.map, "Barrio", "Centro"),
                const Divider(height: 15),
                _campoInfo(Icons.note, "Indicaciones para llegar", "Casa color blanca, portón negro"),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Resumen de entrega", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                SizedBox(height: 6),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Tiempo estimado", style: TextStyle(fontSize: 11, color: Colors.grey)), Text("30 - 45 min", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))]),
                SizedBox(height: 4),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Costo de domicilio", style: TextStyle(fontSize: 11, color: Colors.grey)), Text("\$8.000", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))]),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const Pedidos()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: rojo,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            ),
            child: const Text("Confirmar domicilio", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _campoInfo(IconData icono, String titulo, String valor) {
    return Row(
      children: [
        Icon(icono, size: 18, color: Colors.grey),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              Text(valor, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const Icon(Icons.close, size: 16, color: Colors.grey),
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
                    IconButton(icon: const Icon(Icons.receipt_long_outlined, color: Colors.brown), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Pedidos()))),
                    IconButton(icon: const Icon(Icons.person_outline, color: Colors.brown), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Perfil()))),
                  ],
                ),
                Positioned(
                  top: -24,
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.buttonOrange,
                    child: IconButton(icon: const Icon(Icons.shopping_cart, color: Colors.white, size: 28), onPressed: () {}),
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