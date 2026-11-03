import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../app_colors.dart';
import '../pantallas/metodopagoselector.dart';
import '../services/cart_service.dart';
import '../services/restaurant_order_service.dart';

class DomicilioPantalla extends StatefulWidget {
  const DomicilioPantalla({super.key});

  @override
  State<DomicilioPantalla> createState() => _DomicilioPantallaState();
}

class _DomicilioPantallaState extends State<DomicilioPantalla> {
  static const double _costoDomicilio = 8000;

  final RestaurantOrderService _orders = RestaurantOrderService();
  final _form = GlobalKey<FormState>();
  final _receptor = TextEditingController();
  final _telefono = TextEditingController();
  final _correo = TextEditingController();
  final _direccion = TextEditingController();
  final _barrio = TextEditingController();
  final _indicaciones = TextEditingController();
  final MapController _mapController = MapController();
  LatLng _ubicacion = const LatLng(2.1994, -75.6297);
  String _metodoPago = 'Efectivo';
  bool _seleccionarEnMapa = false;
  bool _enviando = false;

  @override
  void dispose() {
    for (final c in [
      _receptor,
      _telefono,
      _correo,
      _direccion,
      _barrio,
      _indicaciones,
    ]) {
      c.dispose();
    }
    _mapController.dispose();
    super.dispose();
  }

  String get _direccionCompleta => [
    _direccion.text.trim(),
    _barrio.text.trim().isEmpty ? null : 'Barrio ${_barrio.text.trim()}',
    _indicaciones.text.trim().isEmpty
        ? null
        : 'Indicaciones: ${_indicaciones.text.trim()}',
    'Coordenadas: ${_ubicacion.latitude.toStringAsFixed(6)}, ${_ubicacion.longitude.toStringAsFixed(6)}',
  ].whereType<String>().join(', ');

  Future<void> _confirmarDomicilio() async {
    if (!_form.currentState!.validate()) return;
    if (CartService.instance.isEmpty) {
      return _mostrarError(
        'El carrito está vacío. Agrega productos antes de continuar.',
      );
    }
    setState(() => _enviando = true);
    try {
      await _orders.crearPedidoCliente(
        tipoPedido: 'domicilio',
        productos: CartService.instance.toOrderItems(),
        direccionEntrega: _direccionCompleta,
        nombreReceptor: _receptor.text.trim(),
        telefonoReceptor: _telefono.text.trim(),
        correoContacto: _correo.text.trim(),
        metodoPago: _metodoPago,
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
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.red.shade700),
    );
  }

  String? _obligatorio(String? v, String campo) =>
      (v == null || v.trim().isEmpty) ? 'Escribe $campo' : null;

  Widget _campo(
    String label,
    IconData icono,
    TextEditingController c, {
    String? hint,
    TextInputType tipo = TextInputType.text,
    int maxLines = 1,
    bool obligatorio = true,
    List<TextInputFormatter>? formatos,
    String? Function(String?)? validar,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: c,
        keyboardType: tipo,
        maxLines: maxLines,
        inputFormatters: formatos,
        textInputAction: TextInputAction.next,
        validator:
            validar ??
            (obligatorio ? (v) => _obligatorio(v, label.toLowerCase()) : null),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icono),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  String _precio(double v) => v
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');

  @override
  Widget build(BuildContext context) {
    final total = CartService.instance.subtotal + _costoDomicilio;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Datos de entrega'),
        backgroundColor: AppColors.barraHome,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              '¿Quién recibe el pedido?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            _campo('Nombre de quien recibe', Icons.person_outline, _receptor),
            _campo(
              'Teléfono',
              Icons.phone_outlined,
              _telefono,
              tipo: TextInputType.phone,
              formatos: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              validar: (v) => RegExp(r'^\d{10}$').hasMatch(v ?? '')
                  ? null
                  : 'Escribe un teléfono de 10 dígitos',
            ),
            _campo(
              'Correo (opcional, para seguimiento)',
              Icons.email_outlined,
              _correo,
              tipo: TextInputType.emailAddress,
              obligatorio: false,
              validar: (v) =>
                  (v == null ||
                      v.trim().isEmpty ||
                      RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$').hasMatch(v.trim()))
                  ? null
                  : 'Correo no válido',
            ),
            const SizedBox(height: 6),
            const Text(
              '¿A dónde llevamos tu pedido?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            _campo(
              'Dirección',
              Icons.location_on_outlined,
              _direccion,
              hint: 'Calle, carrera, número',
            ),
            _campo('Barrio o zona', Icons.home_outlined, _barrio),
            _campo(
              'Indicaciones adicionales',
              Icons.edit_note,
              _indicaciones,
              hint: 'Casa, apartamento, punto de referencia',
              maxLines: 2,
              obligatorio: false,
            ),
            OutlinedButton.icon(
              onPressed: () =>
                  setState(() => _seleccionarEnMapa = !_seleccionarEnMapa),
              icon: Icon(_seleccionarEnMapa ? Icons.check : Icons.map_outlined),
              label: Text(
                _seleccionarEnMapa
                    ? 'Toca el mapa para elegir la ubicación'
                    : 'Elegir ubicación en el mapa',
              ),
            ),
            const SizedBox(height: 8),
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
            const SizedBox(height: 16),
            MetodoPagoSelector(
              seleccionado: _metodoPago,
              onChanged: (m) => setState(() => _metodoPago = m),
            ),
            const Divider(height: 28),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.delivery_dining,
                color: AppColors.barraHome,
              ),
              title: const Text('Costo de domicilio'),
              trailing: Text('\$${_precio(_costoDomicilio)} COP'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Total a pagar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: Text(
                '\$${_precio(total)} COP',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.barraHome,
                ),
              ),
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
      ),
    );
  }
}
