import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../app_colors.dart';
import '../services/cart_service.dart';
import '../services/restaurant_order_service.dart';

class DomicilioPantalla extends StatefulWidget {
  const DomicilioPantalla({super.key});

  @override
  State<DomicilioPantalla> createState() => _DomicilioPantallaState();
}

class _DomicilioPantallaState extends State<DomicilioPantalla> {
  final RestaurantOrderService _orders = RestaurantOrderService();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _barrioController = TextEditingController();
  final TextEditingController _indicacionesController = TextEditingController();
  final MapController _mapController = MapController();
  LatLng _ubicacion = const LatLng(2.1994, -75.6297);
  bool _seleccionarEnMapa = false;
  bool _enviando = false;

  @override
  void dispose() {
    _direccionController.dispose();
    _barrioController.dispose();
    _indicacionesController.dispose();
    super.dispose();
  }

  String get _direccionCompleta => [
    _direccionController.text.trim(),
    _barrioController.text.trim().isEmpty
        ? null
        : 'Barrio ${_barrioController.text.trim()}',
    _indicacionesController.text.trim().isEmpty
        ? null
        : 'Indicaciones: ${_indicacionesController.text.trim()}',
    'Coordenadas: ${_ubicacion.latitude.toStringAsFixed(6)}, ${_ubicacion.longitude.toStringAsFixed(6)}',
  ].whereType<String>().join(', ');

  Future<void> _confirmarDomicilio() async {
    if (_direccionController.text.trim().isEmpty) {
      _mostrarError('Escribe la dirección de entrega.');
      return;
    }
    if (CartService.instance.isEmpty) {
      _mostrarError('El carrito está vacío. Agrega productos antes de continuar.');
      return;
    }

    setState(() => _enviando = true);
    try {
      await _orders.crearPedidoCliente(
        tipoPedido: 'domicilio',
        productos: CartService.instance.toOrderItems(),
        direccionEntrega: _direccionCompleta,
      );
      CartService.instance.clear();
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      _mostrarError(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.red.shade700),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Datos de entrega'),
        backgroundColor: AppColors.barraHome,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            '¿A dónde llevamos tu pedido?',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _direccionController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Dirección',
              hintText: 'Calle, carrera, número o dirección',
              prefixIcon: Icon(Icons.location_on_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _barrioController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Barrio o zona',
              prefixIcon: Icon(Icons.home_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _indicacionesController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Indicaciones adicionales',
              hintText: 'Casa, apartamento, punto de referencia',
              prefixIcon: Icon(Icons.edit_note),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => setState(
              () => _seleccionarEnMapa = !_seleccionarEnMapa,
            ),
            icon: Icon(
              _seleccionarEnMapa ? Icons.check : Icons.map_outlined,
            ),
            label: Text(
              _seleccionarEnMapa
                  ? 'Toca el mapa para elegir la ubicación'
                  : 'Elegir ubicación en el mapa',
            ),
          ),
          SizedBox(
            height: 210,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _ubicacion,
                  initialZoom: 15,
                  onTap: (_, point) {
                    if (!_seleccionarEnMapa) return;
                    setState(() {
                      _ubicacion = point;
                      _seleccionarEnMapa = false;
                    });
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.elparchee.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _ubicacion,
                        width: 42,
                        height: 42,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.delivery_dining, color: AppColors.barraHome),
            title: Text('Costo de domicilio'),
            trailing: Text('\$8.000 COP'),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _enviando ? null : _confirmarDomicilio,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.barraHome,
                foregroundColor: Colors.white,
              ),
              icon: _enviando
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.check),
              label: Text(
                _enviando ? 'Enviando pedido...' : 'Confirmar domicilio',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
