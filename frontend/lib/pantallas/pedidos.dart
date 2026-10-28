import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_colors.dart';
import '../components/customer_bottom_navigation.dart';
import '../services/restaurant_order_service.dart';

class Pedidos extends StatefulWidget {
  const Pedidos({super.key});

  @override
  State<Pedidos> createState() => _PedidosState();
}

class _PedidosState extends State<Pedidos> {
  final RestaurantOrderService _orders = RestaurantOrderService();
  List<Map<String, dynamic>> _pedidos = [];
  Timer? _timer;
  bool _cargando = true;
  bool _esUsuario = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    final preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    _esUsuario =
        (preferences.getString('user_role') ?? '').toLowerCase() == 'usuario';
    if (!_esUsuario) {
      setState(() => _cargando = false);
      return;
    }
    await _cargarPedidos();
    _timer = Timer.periodic(
      const Duration(seconds: 10),
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
      final pedidos = await _orders.listarPedidosCliente();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mis pedidos'),
        backgroundColor: AppColors.barraHome,
        foregroundColor: Colors.white,
        actions: [
          if (_esUsuario)
            IconButton(
              tooltip: 'Actualizar pedidos',
              onPressed: _cargarPedidos,
              icon: const Icon(Icons.refresh),
            ),
        ],
      ),
      body: !_esUsuario
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'El historial de compras está disponible únicamente para cuentas de usuario.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : _cargando
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_error!, textAlign: TextAlign.center),
                            TextButton(
                              onPressed: _cargarPedidos,
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _pedidos.isEmpty
                      ? const Center(
                          child: Text('Todavía no has realizado pedidos.'),
                        )
                      : RefreshIndicator(
                          onRefresh: _cargarPedidos,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _pedidos.length,
                            itemBuilder: (context, index) =>
                                _pedidoCard(_pedidos[index]),
                          ),
                        ),
      bottomNavigationBar: const CustomerBottomNavigation(selectedIndex: 2),
    );
  }

  Widget _pedidoCard(Map<String, dynamic> pedido) {
    final estado = (pedido['estado'] ?? 'pendiente')
        .toString()
        .replaceAll('_', ' ');
    final detalles = (pedido['detalle_pedido'] as List<dynamic>?) ?? [];
    final mesa = pedido['numero_mesa']?.toString();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Icon(
          pedido['estado'] == 'listo' || pedido['estado'] == 'entregado'
              ? Icons.check_circle_outline
              : Icons.receipt_long,
          color: AppColors.barraHome,
        ),
        title: Text('Pedido #${pedido['id']}'),
        subtitle: Text(
          '${pedido['tipo_pedido'] ?? 'Pedido'} · $estado',
          style: const TextStyle(color: AppColors.barraHome),
        ),
        trailing: Text(
          '\$${(pedido['total'] as num?)?.toStringAsFixed(0) ?? '0'} COP',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          if (mesa != null)
            _detailRow('Mesa', mesa),
          if ((pedido['direccion_entrega'] ?? '').toString().isNotEmpty)
            _detailRow('Dirección', pedido['direccion_entrega'].toString()),
          ...detalles.map((detalle) {
            final item = Map<String, dynamic>.from(detalle as Map);
            final producto = item['producto'] is Map
                ? Map<String, dynamic>.from(item['producto'] as Map)
                : <String, dynamic>{};
            return _detailRow(
              '${item['cantidad']} × ${producto['nombre'] ?? 'Producto'}',
              '\$${(item['subtotal'] as num?)?.toStringAsFixed(0) ?? '0'}',
            );
          }),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(value, textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }
}
