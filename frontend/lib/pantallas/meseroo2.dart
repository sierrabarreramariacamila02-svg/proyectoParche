import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app_colors.dart';
import '../services/restaurant_order_service.dart';

class TomarPedidoScreen extends StatefulWidget {
  final String numeroMesa;

  const TomarPedidoScreen({super.key, required this.numeroMesa});

  @override
  State<TomarPedidoScreen> createState() => _TomarPedidoScreenState();
}

class _TomarPedidoScreenState extends State<TomarPedidoScreen> {
  final RestaurantOrderService _orders = RestaurantOrderService();
  final Map<String, int> _cantidades = {};
  List<Map<String, dynamic>> _productos = [];
  String _categoriaSeleccionada = 'Todos';
  String _busqueda = '';
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
      final id = producto['id']?.toString() ?? '';
      final precio = _precio(producto['precio']);
      total += precio * (_cantidades[id] ?? 0);
    }
    return total;
  }

  Future<void> _enviarPedido() async {
    if (_cantidades.isEmpty) {
      _mostrarError('Agrega al menos un producto al pedido.');
      return;
    }

    setState(() => _enviando = true);
    try {
      await _orders.crearPedidoMesa(
        numeroMesa: widget.numeroMesa,
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
    final categorias = <String>{
      'Todos',
      ..._productos
          .map((producto) => _texto(producto['categoria']).trim())
          .where((categoria) => categoria.isNotEmpty),
    };
    final productosFiltrados = _productos.where((producto) {
      final categoria = _texto(producto['categoria']).trim();
      final nombre = _texto(producto['nombre']).toLowerCase();
      return (_categoriaSeleccionada == 'Todos' ||
              categoria.toLowerCase() ==
                  _categoriaSeleccionada.toLowerCase()) &&
          nombre.contains(_busqueda.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.barraHome,
        foregroundColor: Colors.white,
        title: Text(
          'Mesa ${widget.numeroMesa} · Menú',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: TextField(
              onChanged: (value) => setState(() => _busqueda = value.trim()),
              decoration: InputDecoration(
                hintText: 'Buscar en todo el menú',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          if (!_cargando && _error == null && categorias.length > 1)
            SizedBox(
              height: 48,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                scrollDirection: Axis.horizontal,
                children: categorias.map((categoria) {
                  final seleccionado = categoria == _categoriaSeleccionada;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(categoria),
                      selected: seleccionado,
                      onSelected: (_) =>
                          setState(() => _categoriaSeleccionada = categoria),
                      selectedColor: AppColors.barraHome,
                      labelStyle: TextStyle(
                        color: seleccionado
                            ? Colors.white
                            : AppColors.barraHome,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
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
                : productosFiltrados.isEmpty
                ? Center(
                    child: Text(
                      _productos.isEmpty
                          ? 'No hay productos disponibles.'
                          : 'No encontramos productos en esta categoría.',
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: productosFiltrados.length,
                    itemBuilder: (context, index) {
                      final producto = productosFiltrados[index];
                      return _productoTile(producto);
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.inputBackground,
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
                        '\$${NumberFormat('#,##0', 'es_CO').format(_total)} COP',
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
                        backgroundColor: AppColors.primaryOrange,
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
    final id = producto['id']?.toString() ?? '';
    final precio = _precio(producto['precio']);
    final cantidad = _cantidades[id] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: const Color(0xFFFFEFEC),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        title: Text(_texto(producto['nombre'], fallback: 'Producto')),
        subtitle: Text(
          '\$${NumberFormat('#,##0', 'es_CO').format(precio)} COP',
        ),
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

  String _texto(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    final text = value.toString();
    return text == 'null' ? fallback : text;
  }

  double _precio(dynamic value) {
    final precio = double.tryParse(value?.toString() ?? '');
    return precio != null && precio.isFinite && precio >= 0 ? precio : 0;
  }
}
