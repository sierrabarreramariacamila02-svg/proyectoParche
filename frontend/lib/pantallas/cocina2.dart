import 'package:flutter/material.dart';

class Cocina2 extends StatefulWidget {
  const Cocina2({super.key});

  @override
  State<Cocina2> createState() => _Cocina2State();
}

class _Cocina2State extends State<Cocina2> {
  bool parrilla1 = true;
  bool parrilla2 = true;
  bool fritura1 = false;
  bool fritura2 = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 243, 230),
      body: Column(
        children: [
          // Encabezado
          Container(
            padding: const EdgeInsets.fromLTRB(15, 50, 15, 15),
            color: const Color.fromARGB(255, 139, 18, 18),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const Expanded(
                  child: Text("Detalle del pedido #120",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ),
                // Logo reemplazado en lugar de la pizza
                const CircleAvatar(
                  radius: 18,
                  backgroundImage: AssetImage('assets/images/Logo_el_parche.png'), 
                ),
              ],
            ),
          ),
          // Barra naranja con tiempo
          Container(
            width: double.infinity,
            color: Colors.orange,
            padding: const EdgeInsets.all(12),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("#120",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                Text("Prep time 09:12m", style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          // Estaciones con checklist
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(15),
              children: [
                _estacion("Estación de parrilla"),
                _itemCheck("Classic Burger", "Coberta con miöns\nPreparación y in cebolla",
                    parrilla1, (v) => setState(() => parrilla1 = v!)),
                _itemCheck("Burger Feet", "Preparación mesa", parrilla2,
                    (v) => setState(() => parrilla2 = v!)),
                const SizedBox(height: 15),
                _estacion("Estación de frituras"),
                _itemCheck("Classic Burger", "Coburta con miöns\nPrépáración y in cebolla",
                    fritura1, (v) => setState(() => fritura1 = v!)),
                _itemCheck("Burger Feet", "Preparación mesa", fritura2,
                    (v) => setState(() => fritura2 = v!)),
                const SizedBox(height: 15),
                const Text("Nota de la comanda",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.orange),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text("mesa 4: Classic burger sin cebolla"),
                ),
              ],
            ),
          ),
          // Botón final
          Padding(
            padding: const EdgeInsets.all(15),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange, foregroundColor: Colors.white),
                child: const Text("Marcar pedido completado"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _estacion(String titulo) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(titulo,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
    );
  }

  Widget _itemCheck(
      String nombre, String detalle, bool valor, Function(bool?) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration:
          BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Checkbox(value: valor, onChanged: onChanged, activeColor: Colors.orange),
          const Icon(Icons.fastfood, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(detalle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}