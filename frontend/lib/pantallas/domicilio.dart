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
        textCapitalization: tipo == TextInputType.emailAddress
            ? TextCapitalization.none
            : TextCapitalization.sentences,
        validator:
            validar ??
            (obligatorio ? (v) => _obligatorio(v, label.toLowerCase()) : null),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icono),
          filled: true,
          fillColor: AppColors.inputBackground.withValues(alpha: 0.55),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: AppColors.barraHome.withValues(alpha: 0.1),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: AppColors.barraHome,
              width: 1.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _section({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.barraHome.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: AppColors.barraHome),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.barraHome,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  String _precio(double v) => v
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');

  @override
  Widget build(BuildContext context) {
    final cart = CartService.instance;
    final total = cart.subtotal + _costoDomicilio;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Finalizar pedido'),
        backgroundColor: AppColors.barraHome,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.barraHome, Color(0xFFB63D24)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.delivery_dining,
                    color: Colors.white,
                    size: 38,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tu pedido, hasta tu puerta',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${cart.items.fold<int>(0, (count, line) => count + line.quantity)} productos · entrega segura',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _section(
              icon: Icons.person_outline,
              title: 'Datos de contacto',
              subtitle: 'Para confirmar y coordinar la entrega',
              child: Column(
                children: [
                  _campo(
                    'Nombre de quien recibe',
                    Icons.person_outline,
                    _receptor,
                  ),
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
                    'Correo (opcional)',
                    Icons.email_outlined,
                    _correo,
                    tipo: TextInputType.emailAddress,
                    obligatorio: false,
                    validar: (v) =>
                        (v == null ||
                            v.trim().isEmpty ||
                            RegExp(
                              r'^[\w.+-]+@[\w-]+\.[\w.-]+$',
                            ).hasMatch(v.trim()))
                        ? null
                        : 'Correo no válido',
                  ),
                ],
              ),
            ),
            _section(
              icon: Icons.location_on_outlined,
              title: 'Dirección de entrega',
              subtitle: 'Indica el destino y marca el punto en el mapa',
              child: Column(
                children: [
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
                    hint: 'Casa, apartamento o punto de referencia',
                    maxLines: 2,
                    obligatorio: false,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => setState(
                        () => _seleccionarEnMapa = !_seleccionarEnMapa,
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.barraHome,
                        side: BorderSide(
                          color: AppColors.barraHome.withValues(alpha: 0.35),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      icon: Icon(
                        _seleccionarEnMapa
                            ? Icons.touch_app_outlined
                            : Icons.map_outlined,
                      ),
                      label: Text(
                        _seleccionarEnMapa
                            ? 'Toca el mapa para marcar tu ubicación'
                            : 'Seleccionar ubicación en el mapa',
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      height: 210,
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
                                  color: AppColors.barraHome,
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Ubicación: ${_ubicacion.latitude.toStringAsFixed(5)}, ${_ubicacion.longitude.toStringAsFixed(5)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black.withValues(alpha: 0.55),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _section(
              icon: Icons.payments_outlined,
              title: 'Forma de pago',
              subtitle: 'Elige cómo quieres pagar tu pedido',
              child: MetodoPagoSelector(
                seleccionado: _metodoPago,
                onChanged: (metodo) => setState(() => _metodoPago = metodo),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Productos'),
                  Text('\$${_precio(cart.subtotal)} COP'),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Domicilio'),
                  Text('\$${_precio(_costoDomicilio)} COP'),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(height: 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    '\$${_precio(total)} COP',
                    style: const TextStyle(
                      color: AppColors.barraHome,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _enviando ? null : _confirmarDomicilio,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.barraHome,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
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
                      : const Icon(Icons.check_circle_outline),
                  label: Text(
                    _enviando ? 'Enviando pedido...' : 'Confirmar domicilio',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
