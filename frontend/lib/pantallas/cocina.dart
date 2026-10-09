import 'package:elparchee/pantallas/cocina2.dart';
import 'package:flutter/material.dart';

class Cocina extends StatefulWidget {
  const Cocina({super.key});

  @override
  State<Cocina> createState() => _CocinaState();
}

class _CocinaState extends State<Cocina> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 243, 230),
      body: Column(
        children: [
          // Encabezado rojo
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            color: const Color.fromARGB(255, 139, 18, 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("Pedidos pendientes!",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                Icon(Icons.refresh, color: Colors.white),
              ],
            ),
          ),
          // Chips de estado
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _chip("nuevos (12)", Colors.orange),
                const SizedBox(width: 8),
                _chip("en preparación (8)", Colors.grey.shade300),
                const SizedBox(width: 8),
                _chip("listos (7)", Colors.grey.shade300),
              ],
            ),
          ),
          // Lista de pedidos
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              children: [
                _pedidoCard(context, "120"),
                const SizedBox(height: 15),
                _pedidoCard(context, "121"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String texto, Color color) {
    return Chip(
      label: Text(texto, style: const TextStyle(fontSize: 12)),
      backgroundColor: color,
    );
  }

  Widget _pedidoCard(BuildContext context, String numero) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("#$numero",
                  style:
                      const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Row(
                children: const [
                  Text("Prep Time: 09:12 min",
                      style: TextStyle(color: Colors.red, fontSize: 12)),
                  Icon(Icons.chevron_right),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          _item("Combo Familiar", 0.9),
          _item("Salchipapas", 0.5),
          _item("Salchipapas", 0.3),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Cocina2()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text("Iniciar Preparación"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(String nombre, double progreso) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          const Icon(Icons.fastfood, size: 18, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(child: Text(nombre, style: const TextStyle(fontSize: 13))),
          SizedBox(
            width: 80,
            child: LinearProgressIndicator(
              value: progreso,
              color: Colors.red,
              backgroundColor: Colors.grey.shade300,
            ),
          ),
        ],
      ),
    );
  }
}
    