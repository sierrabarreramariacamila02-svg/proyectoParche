import 'package:flutter/material.dart';

import '../services/restaurant_order_service.dart';

class TomarPedidoScreen extends StatefulWidget {
  const TomarPedidoScreen({super.key});

  @override
  State<TomarPedidoScreen> createState() => _TomarPedidoScreenState();
}

class _TomarPedidoScreenState extends State<TomarPedidoScreen> {
  final RestaurantOrderService _orders = RestaurantOrderService();
  final TextEditingController _mesaController = TextEditingController();
  final Map<String, int> _cantidades = {};
  List<Map<String, dynamic>> _productos = [];
  bool _cargando = true;
  bool _enviando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  @override
  void dispose() {
    _mesaController.dispose();
    super.dispose();
  }

  Future<void> _cargarProductos() async {
    try {
      final productos = await _orders.listarProductos();
      if (!mounted) return;
      setState(() {
        _productos = productos;
        _cargando = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _cambiarCantidad(String id, int cambio) {
    setState(() {
      final cantidad = (_cantidades[id] ?? 0) + cambio;
      if (cantidad <= 0) {
        _cantidades.remove(id);
      } else {
        _cantidades[id] = cantidad;
      }
    });
  }

  double get _total {
    var total = 0.0;
    for (final producto in _productos) {
      final id = producto['id'].toString();
      final precio = (producto['precio'] as num?)?.toDouble() ?? 0;
      total += precio * (_cantidades[id] ?? 0);
    }
    return total;
  }

  Future<void> _enviarPedido() async {
    final mesa = _mesaController.text.trim();
    if (mesa.isEmpty) {
      _mostrarError('Escribe el número de la mesa.');
      return;
    }
    if (_cantidades.isEmpty) {
      _mostrarError('Agrega al menos un producto al pedido.');
      return;
    }

    setState(() => _enviando = true);
    try {
      await _orders.crearPedidoMesa(
        numeroMesa: mesa,
        productos: _cantidades.entries
            .map((entry) => {'producto_id': entry.key, 'cantidad': entry.value})
            .toList(),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
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
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B1D0F),
        title: const Text(
          'Tomar pedido',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _mesaController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Número de mesa',
                prefixIcon: Icon(Icons.table_restaurant),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          if (_error != null)
            MaterialBanner(
              content: Text(_error!),
              leading: const Icon(Icons.error_outline),
              actions: [
                TextButton(
                  onPressed: _cargarProductos,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : _productos.isEmpty
                ? const Center(child: Text('No hay productos disponibles.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _productos.length,
                    itemBuilder: (context, index) {
                      final producto = _productos[index];
                      return _productoTile(producto);
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFFF5EBE6),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        '\$${_total.toStringAsFixed(0)} COP',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD35400),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _enviando || _cargando ? null : _enviarPedido,
                      icon: _enviando
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.soup_kitchen),
                      label: Text(
                        _enviando ? 'Enviando...' : 'Enviar a cocina',
                      ),
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

  Widget _productoTile(Map<String, dynamic> producto) {
    final id = producto['id'].toString();
    final precio = (producto['precio'] as num?)?.toDouble() ?? 0;
    final cantidad = _cantidades[id] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(producto['nombre']?.toString() ?? 'Producto'),
        subtitle: Text('\$${precio.toStringAsFixed(0)} COP'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: cantidad == 0 ? null : () => _cambiarCantidad(id, -1),
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Text(
              '$cantidad',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: () => _cambiarCantidad(id, 1),
              icon: const Icon(Icons.add_circle_outline),
              color: const Color(0xFFD35400),
            ),
          ],
        ),
      ),
    );
  }
}
