import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:elparchee/app_colors.dart';
import 'package:elparchee/pantallas/pedidos.dart';

class DomicilioPantalla extends StatefulWidget {
  const DomicilioPantalla({super.key});

  @override
  State<DomicilioPantalla> createState() => _DomicilioPantallaState();
}

class _DomicilioPantallaState extends State<DomicilioPantalla> {
  static const Color rojo = AppColors.barraHome;
  static const Color naranja = AppColors.buttonOrange;
  static const Color crema = AppColors.background;

  final MapController _mapController = MapController();
  final LatLng _ubicacionInicial = const LatLng(2.1994, -75.6297); // Coordenadas base (ej. Garzón, Huila)

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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      "Domicilio",
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Icon(Icons.notifications_none, color: Colors.white),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(15),
              children: [
                const Text("Datos de entrega", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: rojo)),
                const SizedBox(height: 4),
                const Text("Confirma tu dirección para continuar con el pedido.", style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 12),
                
                // Buscador simulado
                TextField(
                  decoration: InputDecoration(
                    hintText: "Busca tu dirección...",
                    prefixIcon: const Icon(Icons.search, color: naranja),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 10),

                // Botón elegir en el mapa
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.map, color: naranja),
                  label: const Text("Elegir ubicación en el mapa", style: TextStyle(color: Colors.black87)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: naranja),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
                const SizedBox(height: 10),

                // Mini contenedor del Mapa (siguiendo metodología flutter_map)
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _ubicacionInicial,
                        initialZoom: 15.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.elparchee.app',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _ubicacionInicial,
                              width: 40,
                              height: 40,
                              child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Campos de Formulario de Dirección
                _buildCampoTexto("Dirección", "Calle 10 #12-34", Icons.location_on),
                const SizedBox(height: 10),
                _buildCampoTexto("Barrio", "Centro", Icons.home),
                const SizedBox(height: 10),
                _buildCampoTexto("Indicaciones para llegar", "Casa color blanca, portón negro", Icons.edit_note),
                const SizedBox(height: 20),

                // Resumen de entrega
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Tiempo estimado", style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text("Costo de domicilio", style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("30 - 45 min", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          Text("\$8.000", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Botón Confirmar Domicilio
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const Pedidos()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: rojo,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: const Text("Confirmar domicilio", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampoTexto(String label, String valor, IconData icono) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icono, color: naranja, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                Text(valor, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Icon(Icons.close, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}