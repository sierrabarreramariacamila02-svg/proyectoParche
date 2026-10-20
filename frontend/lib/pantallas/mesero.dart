import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:elparchee/pantallas/mesero2.dart';

class Mesero extends StatefulWidget {
  final String mesaId; // ID o número de la mesa que se va a gestionar

  const Mesero({super.key, this.mesaId = "5"}); // Por defecto mesa 5 si no se pasa

  @override
  State<Mesero> createState() => _MeseroState();
}

class _MeseroState extends State<Mesero> {
  Map<String, dynamic> _datosPedido = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDetallePedido();
  }

  // Función para conectar con el Backend y traer los productos del pedido de la mesa
  Future<void> _cargarDetallePedido() async {
    setState(() => _isLoading = true);
    try {
      // Reemplaza esta URL con el endpoint real de tu API para los pedidos por mesa
      final url = Uri.parse('https://tu-api.com/api/mesas/${widget.mesaId}/pedido');
      
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _datosPedido = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          // Datos de respaldo simulados temporalmente si el backend está vacío
          _datosPedido = {
            "mesa": widget.mesaId,
            "productos": [
              {"nombre": "Hamburguesa clasica x2", "precio": "\$26.000"},
              {"nombre": "Perro caliente x1", "precio": "\$28.000"},
              {"nombre": "Salchipapa x1", "precio": "\$30.000"},
            ],
            "total": "\$84.000"
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error al conectar con el backend de mesero: $e");
      setState(() {
        // Datos de respaldo en caso de error de red
        _datosPedido = {
          "mesa": widget.mesaId,
          "productos": [
            {"nombre": "Hamburguesa clasica x2", "precio": "\$26.000"},
            {"nombre": "Perro caliente x1", "precio": "\$28.000"},
            {"nombre": "Salchipapa x1", "precio": "\$30.000"},
          ],
          "total": "\$84.000"
        };
        _isLoading = false;
      });
    }
  }

  // Función para enviar el pedido a cocina
  Future<void> _enviarACocina() async {
    try {
      final url = Uri.parse('https://tu-api.com/api/pedidos/enviar');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"mesa": widget.mesaId, "estado": "nuevo"})
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("¡Pedido enviado a cocina con éxito!")),
        );
      }
    } catch (e) {
      print("Error al enviar pedido: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    String numeroMesa = _datosPedido['mesa']?.toString() ?? widget.mesaId;
    List<dynamic> productos = _datosPedido['productos'] ?? [];
    String total = _datosPedido['total']?.toString() ?? "\$0";

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 243, 230),
      body: Column(
        children: [
          _encabezado("Tomar pedido"),
          Container(
            width: double.infinity,
            color: const Color.fromARGB(255, 229, 160, 90),
            padding: const EdgeInsets.all(14),
            child: Text("Pedido mesa #$numeroMesa",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.orange))
                : Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Renderiza los productos dinámicamente desde el backend
                        ...productos.map((prod) => _producto(
                              prod['nombre'] ?? '',
                              prod['precio'] ?? '',
                            )),
                        const SizedBox(height: 15),
                        const Divider(thickness: 1),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("TOTAL",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            Text(total,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              await _enviarACocina();
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
                            onPressed: _cargarDetallePedido, // Botón recargar
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: Color.fromARGB(255, 229, 160, 90)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25)),
                            ),
                            child: const Text("Actualizar / Agregar +"),
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
            backgroundImage: AssetImage('assets/images/Logo_el_parche.png'),
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