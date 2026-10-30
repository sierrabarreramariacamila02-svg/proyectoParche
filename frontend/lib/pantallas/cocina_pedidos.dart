import 'dart:async';

import 'package:flutter/material.dart';

import '../services/restaurant_order_service.dart';

class Cocina extends StatefulWidget {
  const Cocina({super.key});

  @override
  State<Cocina> createState() => _CocinaState();
}

class _CocinaState extends State<Cocina> {
  final RestaurantOrderService _orders = RestaurantOrderService();
  List<Map<String, dynamic>> _pedidos = [];
  Timer? _timer;
  bool _cargando = true;
  String? _error;
  String _filtro = 'Todos';

  @override
  void initState() {
    super.initState();
    _cargarPedidos();
    _timer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _cargarPedidos(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _cargarPedidos() async {
    try {
      final pedidos = await _orders.listarPedidosCocina();
      if (!mounted) return;
      setState(() {
        _pedidos = pedidos;
        _error = null;
        _cargando = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
        _cargando = false;
      });
    }
  }

  Future<void> _cambiarEstado(
    Map<String, dynamic> pedido,
    String estado,
  ) async {
    final id = int.tryParse(pedido['id'].toString());
    if (id == null) {
      setState(() => _error = 'El pedido recibido no tiene un identificador válido.');
      return;
    }
    try {
      await _orders.actualizarEstado(id, estado);
      await _cargarPedidos();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  List<Map<String, dynamic>> get _pedidosVisibles {
    final activos = _pedidos.where((pedido) {
      final estado = pedido['estado']?.toString().toLowerCase();
      return estado != 'entregado';
    });
    if (_filtro == 'Todos') return activos.toList();
    final estadoFiltro = switch (_filtro) {
      'Pendientes' => 'pendiente',
      'En preparación' => 'en_preparacion',
      _ => 'listo',
    };
    return activos
        .where((pedido) => pedido['estado']?.toString() == estadoFiltro)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B1D0F),
        title: const Text(
          'Pedidos de cocina',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _cargarPedidos,
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Actualizar pedidos',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              children: ['Todos', 'Pendientes', 'En preparación', 'Listos']
                  .map(
                    (filtro) => ChoiceChip(
                      label: Text(filtro),
                      selected: _filtro == filtro,
                      onSelected: (_) => setState(() => _filtro = filtro),
                    ),
                  )
                  .toList(),
            ),
          ),
          if (_error != null)
            MaterialBanner(
              content: Text(_error!),
              leading: const Icon(Icons.error_outline),
              actions: [
                TextButton(onPressed: _cargarPedidos, child: const Text('Reintentar')),
              ],
            ),
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : _pedidosVisibles.isEmpty
                    ? const Center(child: Text('No hay pedidos para este filtro.'))
                    : RefreshIndicator(
                        onRefresh: _cargarPedidos,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _pedidosVisibles.length,
                          itemBuilder: (context, index) {
                            final pedido = _pedidosVisibles[index];
                            return _tarjetaPedido(pedido);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _tarjetaPedido(Map<String, dynamic> pedido) {
    final estado = pedido['estado']?.toString() ?? 'pendiente';
    final detalles = (pedido['detalle_pedido'] as List<dynamic>?) ?? [];
    final mesa = pedido['numero_mesa']?.toString();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pedido #${pedido['id']}  ·  ${mesa == null ? 'Domicilio' : 'Mesa $mesa'}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              estado.replaceAll('_', ' ').toUpperCase(),
              style: const TextStyle(color: Color(0xFFD35400), fontWeight: FontWeight.w600),
            ),
            const Divider(),
            ...detalles.map((detalle) {
              final item = Map<String, dynamic>.from(detalle as Map);
              final producto = item['producto'] is Map
                  ? Map<String, dynamic>.from(item['producto'] as Map)
                  : <String, dynamic>{};
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Text('${item['cantidad']} × ${producto['nombre'] ?? 'Producto'}'),
              );
            }),
            if (estado == 'pendiente' || estado == 'en_preparacion') ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD35400),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _cambiarEstado(
                    pedido,
                    estado == 'pendiente' ? 'en_preparacion' : 'listo',
                  ),
                  icon: Icon(
                    estado == 'pendiente' ? Icons.soup_kitchen : Icons.check,
                  ),
                  label: Text(
                    estado == 'pendiente'
                        ? 'Comenzar preparación'
                        : 'Marcar como listo',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
