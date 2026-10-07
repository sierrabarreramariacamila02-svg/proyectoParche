import 'package:elparchee/pantallas/mesero2.dart';
import 'package:flutter/material.dart';

class Mesero extends StatefulWidget {
  const Mesero({super.key});

  @override
  State<Mesero> createState() => _MeseroState();
}

class _MeseroState extends State<Mesero> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: const Color.fromARGB(255, 250, 243, 230),
      body: Column(
        children: [
          _encabezado("Tomar pedido"),
          Container(
            width: double.infinity,
            color: const Color.fromARGB(255, 229, 160, 90),
            padding: const EdgeInsets.all(14),
            child: const Text("Pedido mesa #5",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _producto("Hamburguesa clasica x2", "\$26.000"),
                  _producto("Perro caliente x1", "\$28.000"),
                  _producto("Salchipapa x1", "\$30.000"),
                  const SizedBox(height: 15),
                  const Divider(thickness: 1),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("TOTAL",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Text("\$84.000",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Mesero2()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 229, 160, 90),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                      ),
                      child: const Text("Enviar a cocina",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: Color.fromARGB(255, 229, 160, 90)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                      ),
                      child: const Text("Agregar +"),
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
            backgroundImage:  AssetImage('assets/images/Logo_el_parche.png'), 
          ),
        ],
      ),
    );
  }

  Widget _producto(String nombre, String precio) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(nombre, style: const TextStyle(fontSize: 14)),
          Text(precio, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}