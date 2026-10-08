import 'package:flutter/material.dart';

class Carrito extends StatefulWidget {
  const Carrito({super.key});

  @override
  State<Carrito> createState() => _CarritoState();
}

class _CarritoState extends State<Carrito> {
  static const Color rojo = Color.fromARGB(255, 139, 18, 18);
  static const Color naranja = Color.fromARGB(255, 229, 160, 90);
  static const Color crema = Color.fromARGB(255, 250, 243, 230);

  final List<Map<String, dynamic>> items = [
    {"nombre": "Perro Caliente Cargado", "precio": 28000, "cant": 1, "icono": Icons.lunch_dining},
    {"nombre": "Classic Cheddar Burger", "precio": 13000, "cant": 2, "icono": Icons.fastfood},
    {"nombre": "Combo Familiar (Special: 2x1)", "precio": 37000, "cant": 2, "icono": Icons.restaurant},
  ];

  int get total =>
      items.fold(0, (s, i) => s + (i["precio"] as int) * (i["cant"] as int));

  String _fmt(int n) => n
      .toString()
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: crema,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 15),
            color: rojo,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Hola username!",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Icon(Icons.notifications_none, color: Colors.white),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(15),
              children: [
                const Text("Bienvenido al carrito.",
                    style: TextStyle(color: rojo, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                for (int i = 0; i < items.length; i++) _tarjeta(i),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: naranja))),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("TOTAL", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("${_fmt(total)} COP",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    Text("Método de pago",
                        style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold)),
                    SizedBox(width: 15),
                    Icon(Icons.credit_card, size: 20),
                    SizedBox(width: 8),
                    Icon(Icons.account_balance_wallet, size: 20),
                  ],
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: naranja,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(200, 45),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: const Text("Realizar pago"),
                ),
              ],
            ),
          ),
        ],
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
                Text("${_fmt(precio)} COP x $cant",
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
                  _boton(Icons.add, () => setState(() => item["cant"] = cant + 1)),
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