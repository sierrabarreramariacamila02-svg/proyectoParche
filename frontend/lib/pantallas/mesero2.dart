import 'package:flutter/material.dart';

class Mesero2 extends StatefulWidget {
  const Mesero2({super.key});

  @override
  State<Mesero2> createState() => _Mesero2State();
}

class _Mesero2State extends State<Mesero2> {
  String metodoPago = "Efectivo";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 243, 230),
      body: Column(
        children: [
          _encabezado("Detalles del pedido"),
          Container(
            width: double.infinity,
            color: const Color.fromARGB(255, 229, 160, 90),
            padding: const EdgeInsets.all(14),
            child: const Text("Detalles del pedido",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Productos consumidos",
                      style: TextStyle(
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text("Hamburguesa clasica x2"),
                  const Text("Perro caliente x1"),
                  const Text("Salchipapa x1"),
                  const SizedBox(height: 15),
                  const Text("TOTAL : 84.000",
                      style: TextStyle(
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      _metodoChip("Efectivo"),
                      const SizedBox(width: 8),
                      _metodoChip("Tarjeta de credito"),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _metodoChip("Transferencia"),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 60, 60, 70),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                      ),
                      child: const Text("Procesar pago",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _encabezado(String titulo) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 45, 15, 15),
      color: const Color.fromARGB(255, 139, 18, 18),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: Text(titulo,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ),
          const CircleAvatar(
            radius: 18,
            backgroundImage:  AssetImage('assets/images/Logo_el_parche.png'),  // Logo 
          ),
        ],
      ),
    );
  }

  Widget _metodoChip(String nombre) {
    final bool seleccionado = metodoPago == nombre;
    return ChoiceChip(
      label: Text(nombre, style: const TextStyle(fontSize: 12)),
      selected: seleccionado,
      selectedColor: const Color.fromARGB(255, 229, 160, 90),
      onSelected: (valor) => setState(() => metodoPago = nombre),
    );
  }
}