import 'package:flutter/material.dart';
import 'package:elparchee/app_colors.dart';
import 'package:elparchee/components/productos.dart';
import 'package:elparchee/pantallas/buscar.dart';
import 'package:elparchee/pantallas/pedidos.dart';
import 'package:elparchee/pantallas/perfil.dart';
import 'package:elparchee/pantallas/domicilio.dart';

class Carrito extends StatefulWidget {
  const Carrito({super.key});

  @override
  State<Carrito> createState() => _CarritoState();
}

class _CarritoState extends State<Carrito> {
  static const Color rojo = AppColors.barraHome;
  static const Color naranja = AppColors.buttonOrange;
  static const Color crema = AppColors.background;

  int _indiceFiltro = 0;
  bool _esDomicilio = true; // true = Domicilio, false = Recoger en tienda

  final List<String> _filtros = [
    'Productos destacados',
    'Perros calientes y mas',
    'Bebidas',
  ];

  final List<Map<String, dynamic>> items = [
    {"nombre": "Perro Caliente Cargado", "precio": 28000, "cant": 1, "icono": Icons.lunch_dining},
    {"nombre": "Classic Cheddar Burger", "precio": 13000, "cant": 2, "icono": Icons.fastfood},
    {"nombre": "Combo Familiar (Special: 2x1)", "precio": 37000, "cant": 2, "icono": Icons.restaurant},
  ];

  int get subtotal =>
      items.fold(0, (s, i) => s + (i["precio"] as int) * (i["cant"] as int));
  
  // Si es domicilio cuesta 8000, si es recoger es 0
  int get costoDomicilio => _esDomicilio ? 8000 : 0;
  int get total => subtotal + costoDomicilio;

  String _fmt(int n) => n
      .toString()
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: crema,
      body: Column(
        children: [
          // Barra superior personalizada con esquinas redondeadas
          Container(
            padding: const EdgeInsets.fromLTRB(10, 50, 20, 15),
            decoration: const BoxDecoration(
              color: rojo,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      "Carrito",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.notifications_none, color: Colors.white),
              ],
            ),
          ),
          
          // Contenido principal de la lista y opciones
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(15),
              children: [
                for (int i = 0; i < items.length; i++) _tarjeta(i),
                const SizedBox(height: 10),
                
                // Sección: Tipo de pedido (Recoger vs Domicilio)
                const Text("Tipo de pedido", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    // Opción: Recoger
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _esDomicilio = false),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: !_esDomicilio ? naranja.withValues(alpha: 0.15) : Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: !_esDomicilio ? naranja : Colors.grey.shade300,
                              width: 1.5,
                            ),
                          ),
                          child: Stack(
                            children: [
                              const Column(
                                children: [
                                  Icon(Icons.store, color: Colors.brown, size: 26),
                                  SizedBox(height: 5),
                                  Text("Recoger", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  Text("Listo en tienda", style: TextStyle(fontSize: 10, color: Colors.grey)),
                                ],
                              ),
                              if (!_esDomicilio)
                                const Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Icon(Icons.check_circle, color: naranja, size: 16),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    // Opción: Domicilio
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _esDomicilio = true),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _esDomicilio ? naranja.withValues(alpha: 0.15) : Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: _esDomicilio ? naranja : Colors.grey.shade300,
                              width: 1.5,
                            ),
                          ),
                          child: Stack(
                            children: [
                              const Column(
                                children: [
                                  Icon(Icons.delivery_dining, color: Colors.brown, size: 26),
                                  SizedBox(height: 5),
                                  Text("Domicilio", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  Text("Te lo llevamos", style: TextStyle(fontSize: 10, color: Colors.grey)),
                                ],
                              ),
                              if (_esDomicilio)
                                const Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Icon(Icons.check_circle, color: naranja, size: 16),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Sección inferior: Totales y botón Continuar dinámico
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, -3))],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Subtotal", style: TextStyle(color: Colors.grey)),
                    Text("\$${_fmt(subtotal)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Domicilio", style: TextStyle(color: Colors.grey)),
                    Text(
                      _esDomicilio ? "\$${_fmt(costoDomicilio)}" : "GRATIS",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _esDomicilio ? Colors.black : Colors.green,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("\$${_fmt(total)} COP",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: rojo)),
                  ],
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {
                    if (_esDomicilio) {
                      // Flujo si elige Domicilio: va a la pantalla de mapas/dirección
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DomicilioPantalla()),
                      );
                    } else {
                      // Flujo si elige Recoger: va directo a Pedidos confirmados
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const Pedidos()),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: naranja,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: Text(
                    _esDomicilio ? "Continuar con domicilio" : "Confirmar pedido para recoger",
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      
      // Barra de navegación inferior
      bottomNavigationBar: Container(
        color: AppColors.barraInferior,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
              top: 12,
              bottom: 8,
              left: 16,
              right: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 30,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.home_outlined, color: Colors.brown),
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const Productos()),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.search, color: Colors.brown),
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const Buscar()),
                              );
                            },
                          ),
                          const SizedBox(width: 50),
                          IconButton(
                            icon: const Icon(Icons.receipt_long_outlined, color: Colors.brown),
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const Pedidos()),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.person_outline, color: Colors.brown),
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const Perfil()),
                              );
                            },
                          ),
                        ],
                      ),
                      Positioned(
                        top: -24,
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.buttonOrange,
                          child: IconButton(
                            icon: const Icon(
                              Icons.shopping_cart,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: () {},
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.barraInferior,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: List.generate(
                      _filtros.length,
                      (i) => Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _indiceFiltro = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _indiceFiltro == i
                                  ? AppColors.buttonOrange
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Text(
                              _filtros[i],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _indiceFiltro == i
                                    ? Colors.black
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tarjeta(int i) {
    final item = items[i];
    final int cant = item["cant"];
    final int precio = item["precio"];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 242, 234, 216),
                borderRadius: BorderRadius.circular(8)),
            child: Icon(item["icono"], color: Colors.deepOrange, size: 36),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item["nombre"], style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("${_fmt(precio)} COP x$cant",
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
                Text("\$${_fmt(precio * cant)}",
                    style: const TextStyle(color: rojo, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  _boton(Icons.remove, () {
                    if (cant > 1) setState(() => item["cant"] = cant - 1);
                  }),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text("$cant"),
                  ),
                  _boton(Icons.add, () => setState(() => item["cant"] = item["cant"] + 1)),
                ],
              ),
              TextButton.icon(
                onPressed: () => setState(() => items.removeAt(i)),
                icon: const Icon(Icons.delete_outline, size: 14, color: Colors.black54),
                label: const Text("Eliminar",
                    style: TextStyle(fontSize: 11, color: Colors.black54)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _boton(IconData icono, VoidCallback onTap) => InkWell(
        onTap: onTap,
        child: CircleAvatar(
          radius: 10,
          backgroundColor: naranja,
          child: Icon(icono, size: 14, color: Colors.white),
        ),
      );
}