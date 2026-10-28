import 'dart:async';

import 'package:flutter/material.dart';

import '../services/restaurant_order_service.dart';
import 'meseroo2.dart';

class GestionMesas extends StatefulWidget {
  final bool adminMode;

  const GestionMesas({super.key, this.adminMode = false});

  @override
  State<GestionMesas> createState() => _GestionMesasState();
}

class _GestionMesasState extends State<GestionMesas> {
  final RestaurantOrderService _orders = RestaurantOrderService();
  List<Map<String, dynamic>> _pedidos = [];
  final Set<String> _pedidosListosNotificados = {};
  Timer? _timer;
  bool _cargando = true;
  bool _primeraCarga = true;
  String? _error;

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
      final pedidos = widget.adminMode
          ? await _orders.listarTodosLosPedidos()
          : await _orders.listarPedidosMesero();
      if (!mounted) return;

      final listos = pedidos
          .where((pedido) => pedido['estado']?.toString() == 'listo')
          .toList();
      final nuevosListos = listos.where(
        (pedido) =>
            !_pedidosListosNotificados.contains(pedido['id'].toString()),
      );
      final debeNotificar = !_primeraCarga && nuevosListos.isNotEmpty;
      final mesaLista = debeNotificar
          ? nuevosListos.first['numero_mesa']?.toString()
          : null;

      setState(() {
        _pedidos = pedidos;
        _error = null;
        _cargando = false;
        _primeraCarga = false;
        _pedidosListosNotificados
          ..clear()
          ..addAll(listos.map((pedido) => pedido['id'].toString()));
      });

      if (debeNotificar && mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                mesaLista == null
                    ? 'Un pedido está listo para entregar.'
                    : 'El pedido de la mesa $mesaLista está listo para entregar.',
              ),
              duration: const Duration(seconds: 6),
              backgroundColor: Colors.green.shade700,
            ),
          );
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
        _cargando = false;
      });
    }
  }

  Future<void> _crearPedido() async {
    final creado = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const TomarPedidoScreen()));
    if (creado == true) {
      await _cargarPedidos();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pedido enviado a cocina.')));
    }
  }

  Future<void> _marcarEntregado(Map<String, dynamic> pedido) async {
    final id = int.tryParse(pedido['id'].toString());
    if (id == null) {
      setState(() => _error = 'El pedido no tiene un identificador válido.');
      return;
    }
    try {
      await _orders.actualizarEstado(id, 'entregado');
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

  @override
  Widget build(BuildContext context) {
    final activos = _pedidos
        .where((pedido) => pedido['estado']?.toString() != 'entregado')
        .toList();
    final listos = activos
        .where((pedido) => pedido['estado']?.toString() == 'listo')
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B1D0F),
        title: Text(
          widget.adminMode ? 'Pedidos de todas las mesas' : 'Pedidos de mis mesas',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
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
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _resumen(
                  'Activos',
                  '${activos.length}',
                  const Color(0xFF6B1D0F),
                ),
                const SizedBox(width: 10),
                _resumen(
                  'Listos para entregar',
                  '$listos',
                  Colors.green.shade700,
                ),
              ],
            ),
          ),
          if (_error != null)
            MaterialBanner(
              content: Text(_error!),
              leading: const Icon(Icons.error_outline),
              actions: [
                TextButton(
                  onPressed: _cargarPedidos,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : activos.isEmpty
                ? const Center(child: Text('Aún no tienes pedidos activos.'))
                : RefreshIndicator(
                    onRefresh: _cargarPedidos,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: activos.length,
                      itemBuilder: (context, index) =>
                          _tarjetaPedido(activos[index]),
                    ),
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD35400),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _crearPedido,
                  icon: const Icon(Icons.add),
                  label: const Text('Tomar pedido'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resumen(String titulo, String cantidad, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 4),
            Text(
              cantidad,
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tarjetaPedido(Map<String, dynamic> pedido) {
    final estado = pedido['estado']?.toString() ?? 'pendiente';
    final mesa = pedido['numero_mesa']?.toString();
    final detalles = (pedido['detalle_pedido'] as List<dynamic>?) ?? [];
    final estaListo = estado == 'listo';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.table_restaurant, color: Color(0xFF6B1D0F)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    mesa == null ? 'Pedido #${pedido['id']}' : 'Mesa $mesa',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Chip(
                  label: Text(
                    estado.replaceAll('_', ' '),
                    style: TextStyle(
                      color: estaListo ? Colors.green.shade800 : Colors.black87,
                    ),
                  ),
                  backgroundColor: estaListo
                      ? Colors.green.shade100
                      : Colors.orange.shade100,
                ),
              ],
            ),
            Text('Pedido #${pedido['id']}'),
            const Divider(),
            ...detalles.map((detalle) {
              final item = Map<String, dynamic>.from(detalle as Map);
              final producto = item['producto'] is Map
                  ? Map<String, dynamic>.from(item['producto'] as Map)
                  : <String, dynamic>{};
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Text(
                  '${item['cantidad']} × ${producto['nombre'] ?? 'Producto'}',
                ),
              );
            }),
            if (estaListo) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _marcarEntregado(pedido),
                  icon: const Icon(Icons.check),
                  label: const Text('Marcar como entregado'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
