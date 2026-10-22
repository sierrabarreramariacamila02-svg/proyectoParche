import 'package:flutter/material.dart';
import 'package:elparchee/app_colors.dart';
import 'package:elparchee/components/productos.dart';
import 'package:elparchee/pantallas/buscar.dart';
import 'package:elparchee/pantallas/perfil.dart';
import 'package:elparchee/pantallas/carrito.dart';

class Pedidos extends StatelessWidget {
  const Pedidos({super.key});

  static const Color rojo = AppColors.barraHome;
  static const Color naranja = AppColors.buttonOrange;
  static const Color crema = AppColors.background;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: crema,
      body: Column(
        children: [
          // Barra Superior
          Container(
            padding: const EdgeInsets.fromLTRB(10, 50, 20, 15),
            decoration: const BoxDecoration(
              color: rojo,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Pedidos",
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.notifications_none, color: Colors.white),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(15),
              children: [
                // Tarjeta de Pedido Confirmado
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
                  ),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 25,
                        backgroundColor: naranja,
                        child: Icon(Icons.check, color: Colors.white, size: 30),
                      ),
                      const SizedBox(height: 10),
                      const Text("¡Pedido confirmado!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: rojo)),
                      const SizedBox(height: 5),
                      const Text("Tu pedido #1234 ha sido recibido y está en proceso.", 
                        textAlign: TextAlign.center, 
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: crema,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delivery_dining, color: naranja),
                            SizedBox(width: 10),
                            Text("Tiempo estimado de entrega\n30 - 45 min", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Línea de estados del pedido
                      _buildPasoEstado("Pedido recibido", "12:10 p.m.", true, true),
                      _buildPasoEstado("En preparación", "12:15 p.m.", true, true),
                      _buildPasoEstado("En camino", "Pendiente", false, true),
                      _buildPasoEstado("Entregado", "Pendiente", false, false),

                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: naranja,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 40),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text("Ver seguimiento"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: AppColors.barraInferior,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.home_outlined, color: Colors.brown),
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Productos())),
                ),
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.brown),
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Buscar())),
                ),
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined, color: Colors.brown),
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Carrito())),
                ),
                IconButton(
                  icon: const Icon(Icons.receipt_long, color: naranja), // Activo en Pedidos
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.person_outline, color: Colors.brown),
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Perfil())),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasoEstado(String titulo, String hora, bool completado, bool mostrarLinea) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: completado ? naranja : Colors.grey.shade300,
              ),
              child: Icon(completado ? Icons.check : Icons.circle, size: 12, color: Colors.white),
            ),
            if (mostrarLinea)
              Container(
                width: 2,
                height: 30,
                color: completado ? naranja : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(titulo, style: TextStyle(fontWeight: FontWeight.bold, color: completado ? Colors.black : Colors.grey)),
              Text(hora, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }
}