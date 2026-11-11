import 'dart:async';

import 'package:elparchee/app_colors.dart';
import 'package:elparchee/services/restaurant_order_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'admin_drawer.dart';

class AdminDeliveriesPage extends StatefulWidget {
  const AdminDeliveriesPage({super.key});

  @override
  State<AdminDeliveriesPage> createState() => _AdminDeliveriesPageState();
}

class _AdminDeliveriesPageState extends State<AdminDeliveriesPage> {
  final RestaurantOrderService _orders = RestaurantOrderService();
  final NumberFormat _currency = NumberFormat('#,##0', 'es_CO');
  final Set<String> _updating = {};
  List<Map<String, dynamic>> _deliveries = [];
  Timer? _timer;
  String _adminName = '';
  String _adminEmail = '';
  String _filter = 'Activos';
  String? _error;
  bool _loading = true;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _loadAdmin();
    _loadDeliveries();
    _timer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _loadDeliveries(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadAdmin() async {
    final preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _adminName = preferences.getString('user_name') ?? 'Administrador';
      _adminEmail = preferences.getString('user_email') ?? '';
    });
  }

  Future<void> _loadDeliveries() async {
    if (_refreshing) return;
    _refreshing = true;
    try {
      final orders = await _orders.listarTodosLosPedidos();
      if (!mounted) return;
      setState(() {
        _deliveries = orders
            .where((order) => order['tipo_pedido']?.toString() == 'domicilio')
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

  List<Map<String, dynamic>> get _visibleDeliveries {
    final filtered = _filter == 'Activos'
        ? _deliveries.where((order) => order['estado'] != 'entregado')
        : _deliveries.where((order) => order['estado'] == 'entregado');
    return filtered.toList();
  }

  Future<void> _changeStatus(
    Map<String, dynamic> order,
    String nextStatus,
  ) async {
    final id = order['id']?.toString();
    final orderId = int.tryParse(id ?? '');
    if (orderId == null || _updating.contains(id)) return;

    setState(() => _updating.add(id!));
    try {
      await _orders.actualizarEstado(orderId, nextStatus);
      await _loadDeliveries();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            nextStatus == 'en_camino'
                ? 'Pedido #$id marcado en camino.'
                : 'Pedido #$id marcado como entregado.',
          ),
          backgroundColor: AppColors.barraHome,
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
      if (mounted) setState(() => _updating.remove(id));
    }
  }

  String _statusLabel(String status) => switch (status) {
    'pendiente' => 'Esperando cocina',
    'en_preparacion' => 'En preparación',
    'listo' => 'Listo para salir',
    'en_camino' => 'En camino',
    'entregado' => 'Entregado',
    _ => status.replaceAll('_', ' '),
  };

  Color _statusColor(String status) => switch (status) {
    'listo' => Colors.green.shade700,
    'en_camino' => Colors.deepOrange.shade700,
    'entregado' => Colors.blueGrey,
    'en_preparacion' => Colors.orange.shade800,
    _ => AppColors.barraHome,
  };

  String _formatAmount(dynamic value) {
    final amount = num.tryParse(value?.toString() ?? '') ?? 0;
    return '\$${_currency.format(amount)} COP';
  }

  String _dateLabel(Map<String, dynamic> order) {
    final rawDate = order['creado_en'] ?? order['created_at'];
    final date = DateTime.tryParse(rawDate?.toString() ?? '');
    if (date == null) return 'Hora no disponible';
    return DateFormat('dd/MM/yyyy · HH:mm').format(date.toLocal());
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
    final deliveries = _visibleDeliveries;
    final activeCount = _deliveries
        .where((order) => order['estado'] != 'entregado')
        .length;
    final readyCount = _deliveries
        .where((order) => order['estado'] == 'listo')
        .length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Domicilios',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.barraHome,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Actualizar pedidos',
            onPressed: _refreshing ? null : _loadDeliveries,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      drawer: AdminDrawer(adminName: _adminName, adminEmail: _adminEmail),
      body: RefreshIndicator(
        color: AppColors.barraHome,
        onRefresh: _loadDeliveries,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            _overview(activeCount, readyCount),
            const SizedBox(height: 18),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'Activos',
                  icon: Icon(Icons.delivery_dining),
                  label: Text('Activos'),
                ),
                ButtonSegment(
                  value: 'Entregados',
                  icon: Icon(Icons.task_alt),
                  label: Text('Entregados'),
                ),
              ],
              selected: {_filter},
              onSelectionChanged: (selection) =>
                  setState(() => _filter = selection.first),
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? Colors.white
                      : AppColors.barraHome,
                ),
                backgroundColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? AppColors.barraHome
                      : Colors.white,
                ),
                side: WidgetStateProperty.all(
                  BorderSide(
                    color: AppColors.barraHome.withValues(alpha: 0.18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            if (_error != null)
              MaterialBanner(
                content: Text(_error!),
                leading: const Icon(Icons.error_outline),
                actions: [
                  TextButton(
                    onPressed: _loadDeliveries,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(36),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.barraHome),
                ),
              )
            else if (deliveries.isEmpty)
              _emptyState()
            else
              ...deliveries.map(_deliveryCard),
          ],
        ),
      ),
    );
  }

  Widget _overview(int activeCount, int readyCount) {
    return Container(
      padding: const EdgeInsets.all(18),
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
          const Icon(Icons.delivery_dining, color: Colors.white, size: 38),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Entregas del restaurante',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$activeCount activos · $readyCount listos para salir',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.autorenew, color: Colors.white70),
        ],
      ),
    );
  }

  Widget _deliveryCard(Map<String, dynamic> order) {
    final id = order['id']?.toString() ?? '—';
    final status = order['estado']?.toString() ?? 'pendiente';
    final color = _statusColor(status);
    final address = order['direccion_entrega']?.toString().trim() ?? '';
    final name = order['nombre_receptor']?.toString().trim() ?? '';
    final phone = order['telefono_receptor']?.toString().trim() ?? '';
    final payment = order['metodo_pago']?.toString().trim() ?? '';
    final details = _details(order);
    final busy = _updating.contains(id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: AppColors.barraHome.withValues(alpha: 0.1),
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
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.receipt_long, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pedido #$id',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _dateLabel(order),
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.55),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                _statusBadge(_statusLabel(status), color),
              ],
            ),
            const SizedBox(height: 14),
            if (name.isNotEmpty) _infoRow(Icons.person_outline, 'Recibe', name),
            if (phone.isNotEmpty)
              _infoRow(Icons.phone_outlined, 'Teléfono', phone),
            if (address.isNotEmpty)
              _infoRow(Icons.location_on_outlined, 'Dirección', address),
            if (payment.isNotEmpty)
              _infoRow(Icons.payments_outlined, 'Pago', payment),
            if (address.isEmpty && name.isEmpty && phone.isEmpty)
              _infoRow(
                Icons.info_outline,
                'Entrega',
                'Faltan los datos de domicilio. Revisa la migración de base de datos.',
              ),
            if (details.isNotEmpty) ...[
              const Divider(height: 22),
              ...details.map(_detailLine),
            ],
            const Divider(height: 22),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Total',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  _formatAmount(order['total']),
                  style: const TextStyle(
                    color: AppColors.barraHome,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (status == 'listo' || status == 'en_camino') ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: busy
                      ? null
                      : () => _changeStatus(
                          order,
                          status == 'listo' ? 'en_camino' : 'entregado',
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.barraHome,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  icon: busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          status == 'listo'
                              ? Icons.local_shipping_outlined
                              : Icons.check_circle_outline,
                        ),
                  label: Text(
                    status == 'listo'
                        ? 'Marcar como en camino'
                        : 'Confirmar entrega',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.barraHome),
          const SizedBox(width: 9),
          SizedBox(
            width: 76,
            child: Text(
              label,
              style: TextStyle(color: Colors.black.withValues(alpha: 0.55)),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailLine(Map<String, dynamic> detail) {
    final product = detail['producto'] is Map
        ? Map<String, dynamic>.from(detail['producto'] as Map)
        : <String, dynamic>{};
    final name = product['nombre']?.toString() ?? 'Producto';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(
            '${detail['cantidad'] ?? 0} × ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(name)),
          Text(_formatAmount(detail['subtotal'])),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          Icon(
            _filter == 'Activos'
                ? Icons.delivery_dining_outlined
                : Icons.task_alt_outlined,
            size: 56,
            color: AppColors.barraHome.withValues(alpha: 0.45),
          ),
          const SizedBox(height: 12),
          Text(
            _filter == 'Activos'
                ? 'No hay domicilios activos'
                : 'Aún no hay domicilios entregados',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 5),
          Text(
            'Los pedidos nuevos aparecerán aquí automáticamente.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black.withValues(alpha: 0.55)),
          ),
        ],
      ),
    );
  }
}
