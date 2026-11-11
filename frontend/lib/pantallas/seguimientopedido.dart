import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../app_colors.dart';
import '../services/restaurant_order_service.dart';

/// Seguimiento del domicilio.
/// - Desde "Mis pedidos": SeguimientoPedido(pedidoId: pedido['id'])
/// - Con teléfono o correo: SeguimientoPedido() y el cliente lo escribe.
class SeguimientoPedido extends StatefulWidget {
  const SeguimientoPedido({super.key, this.pedidoId});

  final dynamic pedidoId;

  @override
  State<SeguimientoPedido> createState() => _SeguimientoPedidoState();
}

class _SeguimientoPedidoState extends State<SeguimientoPedido> {
  static const _pasos = [
    ['Pedido recibido', 'receipt_long'],
    ['Preparando', 'restaurant'],
    ['En camino', 'delivery_dining'],
    ['Entregado', 'check_circle'],
  ];
  static const _iconos = {
    'receipt_long': Icons.receipt_long,
    'restaurant': Icons.restaurant,
    'delivery_dining': Icons.delivery_dining,
    'check_circle': Icons.check_circle,
  };

  final RestaurantOrderService _orders = RestaurantOrderService();
  final _contacto = TextEditingController();
  Map<String, dynamic>? _pedido;
  Timer? _timer;
  bool _cargando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.pedidoId != null) _iniciar();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _contacto.dispose();
    super.dispose();
  }

  void _iniciar() {
    _timer?.cancel();
    _consultar();
    // Se actualiza solo cada 8 segundos
    _timer = Timer.periodic(
      const Duration(seconds: 8),
      (_) => _consultar(silencioso: true),
    );
  }

  Future<void> _consultar({bool silencioso = false}) async {
    if (!silencioso) setState(() => _cargando = true);
    try {
      Map<String, dynamic>? pedido;
      if (widget.pedidoId != null) {
        final lista = await _orders.listarPedidosCliente();
        pedido = lista.cast<Map<String, dynamic>?>().firstWhere(
          (p) => p?['id'].toString() == widget.pedidoId.toString(),
          orElse: () => null,
        );
      } else {
        // Debes agregar este método en RestaurantOrderService
        pedido = await _orders.consultarPedidoPorContacto(
          _contacto.text.trim(),
        );
      }
      if (!mounted) return;
      setState(() {
        _pedido = pedido;
        _error = pedido == null
            ? 'No encontramos un domicilio con esos datos.'
            : null;
        _cargando = false;
      });
      if (pedido != null && _paso(pedido) == 3) _timer?.cancel();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _cargando = false;
      });
    }
  }

  void _buscar() {
    final c = _contacto.text.trim();
    if (c.isEmpty) {
      setState(() => _error = 'Escribe tu teléfono o correo.');
      return;
    }
    FocusScope.of(context).unfocus();
    _iniciar();
  }

  int _paso(Map<String, dynamic> p) {
    switch ((p['estado'] ?? 'pendiente').toString()) {
      case 'preparando':
      case 'en_preparacion':
        return 1;
      case 'listo':
      case 'en_camino':
        return 2;
      case 'entregado':
        return 3;
      default:
        return 0;
    }
  }

  LatLng? _coordenadas(String? texto) {
    final m = RegExp(
      r'Coordenadas:\s*(-?\d+\.\d+),\s*(-?\d+\.\d+)',
    ).firstMatch(texto ?? '');
    if (m == null) return null;
    return LatLng(double.parse(m.group(1)!), double.parse(m.group(2)!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Seguimiento del domicilio'),
        backgroundColor: AppColors.barraHome,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (widget.pedidoId == null) ...[
            TextField(
              controller: _contacto,
              keyboardType: TextInputType.emailAddress,
              onSubmitted: (_) => _buscar(),
              decoration: InputDecoration(
                labelText: 'Teléfono o correo',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _buscar,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (_cargando) const Center(child: CircularProgressIndicator()),
          if (_error != null && !_cargando)
            Text(_error!, textAlign: TextAlign.center),
          if (_pedido != null) ..._detalle(_pedido!),
        ],
      ),
    );
  }

  List<Widget> _detalle(Map<String, dynamic> p) {
    final paso = _paso(p);
    final direccion = p['direccion_entrega']?.toString();
    final destino = _coordenadas(direccion);
    final lat = (p['repartidor_lat'] as num?)?.toDouble();
    final lng = (p['repartidor_lng'] as num?)?.toDouble();
    final repartidor = (lat != null && lng != null) ? LatLng(lat, lng) : null;

    return [
      Text(
        'Pedido #${p['id']}',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      const SizedBox(height: 12),
      ...List.generate(_pasos.length, (i) {
        final activo = i <= paso;
        return ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            _iconos[_pasos[i][1]],
            color: activo ? AppColors.barraHome : Colors.black26,
          ),
          title: Text(
            _pasos[i][0],
            style: TextStyle(
              fontWeight: i == paso ? FontWeight.bold : FontWeight.normal,
              color: activo ? Colors.black87 : Colors.black38,
            ),
          ),
          trailing: i == paso
              ? const Icon(Icons.circle, size: 12, color: Colors.green)
              : null,
        );
      }),
      if (direccion != null && direccion.isNotEmpty) ...[
        const Divider(),
        Text('Entrega en: ${direccion.split(', Coordenadas').first}'),
      ],
      if (destino != null) ...[
        const SizedBox(height: 12),
        SizedBox(
          height: 240,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: FlutterMap(
              options: MapOptions(
                initialCenter: repartidor ?? destino,
                initialZoom: 15,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.elparchee.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: destino,
                      width: 42,
                      height: 42,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                    if (repartidor != null)
                      Marker(
                        point: repartidor,
                        width: 42,
                        height: 42,
                        child: const Icon(
                          Icons.delivery_dining,
                          color: AppColors.barraHome,
                          size: 36,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ];
  }
}
