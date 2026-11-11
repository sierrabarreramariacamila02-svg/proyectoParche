import 'dart:async';

import 'package:elparchee/app_colors.dart';
import 'package:elparchee/components/inventario.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'mesero_perfil.dart';
import '../services/restaurant_order_service.dart';

class Cocina extends StatefulWidget {
  const Cocina({super.key});

  @override
  State<Cocina> createState() => _CocinaState();
}

class _CocinaState extends State<Cocina> with SingleTickerProviderStateMixin {
  final RestaurantOrderService _orders = RestaurantOrderService();
  final Set<String> _updatingOrders = {};
  List<Map<String, dynamic>> _ordersList = [];
  Timer? _timer;
  late final TabController _tabController;
  bool _loading = true;
  bool _refreshing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadOrders();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _loadOrders());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    if (_refreshing) return;
    _refreshing = true;
    try {
      final orders = await _orders.listarPedidosCocina();
      if (!mounted) return;
      setState(() {
        _ordersList = orders
            .where((order) => order['estado']?.toString() != 'entregado')
            .toList();
        _error = null;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    } finally {
      _refreshing = false;
    }
  }

  List<Map<String, dynamic>> _byStatus(String status) => _ordersList
      .where((order) => order['estado']?.toString() == status)
      .toList();

  Future<void> _changeStatus(Map<String, dynamic> order, String status) async {
    final id = order['id']?.toString();
    if (id == null || id.isEmpty || _updatingOrders.contains(id)) return;

    setState(() => _updatingOrders.add(id));
    try {
      await _orders.actualizarEstado(int.parse(id), status);
      await _loadOrders();
      if (!mounted) return;
      final ready = status == 'listo';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ready
                ? 'Pedido #$id listo. El mesero recibirá el aviso.'
                : 'Pedido #$id tomado para preparación.',
          ),
          backgroundColor: ready ? Colors.green.shade800 : AppColors.barraHome,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _updatingOrders.remove(id));
    }
  }

  Future<void> _takeNextOrder() async {
    final waiting = _byStatus('pendiente');
    if (waiting.isEmpty) return;
    await _changeStatus(waiting.last, 'en_preparacion');
  }

  String _orderPlace(Map<String, dynamic> order) {
    final type = order['tipo_pedido']?.toString();
    if (type == 'mesa') return 'Mesa ${order['numero_mesa'] ?? '—'}';
    if (type == 'domicilio') return 'Domicilio';
    if (type == 'recoger') return 'Para recoger';
    return 'Pedido';
  }

  String _elapsed(Map<String, dynamic> order) {
    final rawDate = order['creado_en'] ?? order['created_at'];
    final createdAt = DateTime.tryParse(rawDate?.toString() ?? '');
    if (createdAt == null) return 'Hora no disponible';
    final elapsed = DateTime.now().difference(createdAt.toLocal());
    if (elapsed.isNegative) return 'Ahora';
    if (elapsed.inHours > 0) {
      return '${elapsed.inHours} h ${elapsed.inMinutes.remainder(60)} min';
    }
    return '${elapsed.inMinutes} min';
  }

  List<Map<String, dynamic>> _details(Map<String, dynamic> order) {
    final details = order['detalle_pedido'];
    if (details is! List) return [];
    return details
        .whereType<Map>()
        .map((detail) => Map<String, dynamic>.from(detail))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final waiting = _byStatus('pendiente');
    final preparing = _byStatus('en_preparacion');
    final ready = _byStatus('listo');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Cocina',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.barraHome,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Actualizar pedidos',
            onPressed: _refreshing ? null : _loadOrders,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Mi perfil',
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const CocinaPerfilPage())),
            icon: const Icon(Icons.account_circle_outlined),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorSize: TabBarIndicatorSize.label,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          tabs: [
            Tab(text: 'Órdenes (${waiting.length + preparing.length})'),
            const Tab(text: 'Ingredientes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ordersView(waiting, preparing, ready),
          const InventarioScreen(readOnly: true, embedded: true),
        ],
      ),
    );
  }

  Widget _ordersView(
    List<Map<String, dynamic>> waiting,
    List<Map<String, dynamic>> preparing,
    List<Map<String, dynamic>> ready,
  ) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.barraHome),
      );
    }

    return RefreshIndicator(
      color: AppColors.barraHome,
      onRefresh: _loadOrders,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          if (_error != null)
            MaterialBanner(
              content: Text(_error!),
              leading: const Icon(Icons.error_outline),
              actions: [
                TextButton(
                  onPressed: _loadOrders,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          _sectionHeader(
            'Órdenes en espera',
            waiting.length,
            Colors.orange.shade800,
          ),
          if (waiting.isEmpty)
            _emptySection('No hay órdenes pendientes.')
          else
            ...waiting.map(
              (order) => _orderCard(
                order,
                statusLabel: 'Pendiente',
                actionLabel: 'Preparar orden',
                actionIcon: Icons.soup_kitchen_outlined,
                actionColor: AppColors.primaryOrange,
                onAction: () => _changeStatus(order, 'en_preparacion'),
              ),
            ),
          if (waiting.isNotEmpty) ...[
            const SizedBox(height: 4),
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _updatingOrders.isNotEmpty ? null : _takeNextOrder,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.barraHome,
                  side: const BorderSide(color: AppColors.barraHome),
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.skip_next),
                label: const Text('Tomar orden siguiente'),
              ),
            ),
          ],
          const SizedBox(height: 22),
          _sectionHeader(
            'En proceso',
            preparing.length,
            AppColors.primaryOrange,
          ),
          if (preparing.isEmpty)
            _emptySection('No hay órdenes en preparación.')
          else
            ...preparing.map(
              (order) => _orderCard(
                order,
                statusLabel: 'En preparación',
                actionLabel: 'Marcar listo y avisar al mesero',
                actionIcon: Icons.notifications_active_outlined,
                actionColor: AppColors.barraHome,
                onAction: () => _changeStatus(order, 'listo'),
              ),
            ),
          if (ready.isNotEmpty) ...[
            const SizedBox(height: 22),
            _sectionHeader(
              'Listos · Mesero avisado',
              ready.length,
              Colors.green,
            ),
            ...ready.map(
              (order) => _orderCard(
                order,
                statusLabel: 'Listo',
                actionLabel: 'Aviso enviado al mesero',
                actionIcon: Icons.check_circle_outline,
                actionColor: Colors.green.shade800,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.barraHome,
                letterSpacing: 0.35,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptySection(String text) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.72),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.barraHome.withValues(alpha: 0.07)),
    ),
    child: Row(
      children: [
        Icon(
          Icons.check_circle_outline,
          size: 20,
          color: Colors.black.withValues(alpha: 0.4),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: const TextStyle(color: Colors.black54)),
        ),
      ],
    ),
  );

  Widget _orderCard(
    Map<String, dynamic> order, {
    required String statusLabel,
    required String actionLabel,
    required IconData actionIcon,
    required Color actionColor,
    VoidCallback? onAction,
  }) {
    final id = order['id']?.toString() ?? '';
    final updating = _updatingOrders.contains(id);
    final details = _details(order);
    final createdAt = DateTime.tryParse(
      (order['creado_en'] ?? order['created_at'])?.toString() ?? '',
    )?.toLocal();

    return Card(
      color: Colors.white,
      elevation: 2,
      shadowColor: AppColors.barraHome.withValues(alpha: 0.10),
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.barraHome.withValues(alpha: 0.07)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _orderPlace(order),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  _elapsed(order),
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
            Text(
              'Pedido #$id'
              '${createdAt == null ? '' : ' · ${DateFormat('HH:mm').format(createdAt)}'}',
              style: const TextStyle(color: Colors.black54, fontSize: 12),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(
                color: actionColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    statusLabel == 'Pendiente'
                        ? Icons.schedule
                        : statusLabel == 'Listo'
                        ? Icons.check_circle_outline
                        : Icons.local_fire_department_outlined,
                    size: 15,
                    color: actionColor,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    statusLabel,
                    style: TextStyle(
                      color: actionColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 22,
              color: AppColors.barraHome.withValues(alpha: 0.12),
            ),
            if (details.isEmpty)
              const Text('Sin detalles de productos.')
            else
              ...details.map((detail) {
                final product = detail['producto'];
                final name = product is Map
                    ? product['nombre']?.toString() ?? 'Producto'
                    : 'Producto';
                final quantity = detail['cantidad'] ?? 0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Text(
                    '$quantity × $name',
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }),
            if (onAction != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: updating ? null : onAction,
                  style: FilledButton.styleFrom(
                    backgroundColor: actionColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  icon: updating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(actionIcon),
                  label: Text(updating ? 'Actualizando…' : actionLabel),
                ),
              ),
            ] else
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: actionColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(actionIcon, size: 18, color: actionColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        actionLabel,
                        style: TextStyle(
                          color: actionColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
