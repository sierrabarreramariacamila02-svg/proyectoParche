import 'dart:async';

import 'package:elparchee/app_colors.dart';
import 'package:elparchee/services/restaurant_order_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'admin_drawer.dart';

class AdminSalesReportPage extends StatefulWidget {
  const AdminSalesReportPage({super.key});

  @override
  State<AdminSalesReportPage> createState() => _AdminSalesReportPageState();
}

class _AdminSalesReportPageState extends State<AdminSalesReportPage> {
  static const Color _brand = AppColors.barraHome;

  final RestaurantOrderService _orders = RestaurantOrderService();
  final NumberFormat _currency = NumberFormat('#,##0', 'es_CO');
  List<Map<String, dynamic>> _ordersList = [];
  String _selectedPeriod = 'Todo';
  String _selectedType = 'Todos';
  String _adminName = '';
  String _adminEmail = '';
  String? _error;
  bool _loading = true;
  bool _refreshing = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadAdmin();
    _loadOrders();
    _refreshTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      _loadOrders();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
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

  Future<void> _loadOrders() async {
    if (_refreshing) return;
    _refreshing = true;
    if (_ordersList.isEmpty && mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final orders = await _orders.listarTodosLosPedidos();
      if (!mounted) return;
      setState(() {
        _ordersList = orders;
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

  List<Map<String, dynamic>> get _filteredOrders {
    final periodOrders = switch (_selectedPeriod) {
      'Semanal' => _ordersInRange(_startOfCurrentWeek, DateTime.now()),
      'Mensual' => _ordersInRange(_startOfCurrentMonth, DateTime.now()),
      _ => _ordersList,
    };
    if (_selectedType == 'Todos') return periodOrders;

    final type = switch (_selectedType) {
      'Mesas' => 'mesa',
      'Domicilios' => 'domicilio',
      'Para recoger' => 'recoger',
      _ => '',
    };
    return periodOrders
        .where((order) => order['tipo_pedido']?.toString() == type)
        .toList();
  }

  DateTime get _startOfCurrentWeek {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return today.subtract(Duration(days: now.weekday - DateTime.monday));
  }

  DateTime get _startOfCurrentMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  List<Map<String, dynamic>> _ordersInRange(DateTime start, DateTime end) {
    return _ordersList.where((order) {
      final date = _orderDate(order);
      return date != null && !date.isBefore(start) && date.isBefore(end);
    }).toList();
  }

  double _amount(Map<String, dynamic> order) {
    final amount = double.tryParse(order['total']?.toString() ?? '');
    return amount != null && amount.isFinite ? amount : 0;
  }

  String _formatAmount(num amount) => '\$${_currency.format(amount)} COP';

  DateTime? _orderDate(Map<String, dynamic> order) {
    final rawDate = order['creado_en'] ?? order['created_at'];
    final date = DateTime.tryParse(rawDate?.toString() ?? '');
    return date?.toLocal();
  }

  String _orderTitle(Map<String, dynamic> order) {
    if (order['tipo_pedido']?.toString() == 'mesa') {
      return 'Mesa ${order['numero_mesa'] ?? '—'}';
    }
    return switch (order['tipo_pedido']?.toString()) {
      'domicilio' => 'Domicilio',
      'recoger' => 'Para recoger',
      _ => 'Pedido',
    };
  }

  String _dateLabel(Map<String, dynamic> order) {
    final date = _orderDate(order);
    if (date == null) return 'Fecha no disponible';
    return DateFormat('dd/MM/yyyy · HH:mm').format(date);
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
    final orders = _filteredOrders;
    final total = orders.fold<double>(0, (sum, order) => sum + _amount(order));
    final average = orders.isEmpty ? 0.0 : total / orders.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Reporte de ventas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: _brand,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Actualizar reporte',
            onPressed: _refreshing ? null : _loadOrders,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      drawer: AdminDrawer(adminName: _adminName, adminEmail: _adminEmail),
      body: RefreshIndicator(
        color: _brand,
        onRefresh: _loadOrders,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            const Text(
              'Resumen de pedidos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _brand,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Consulta las ventas y pedidos registrados.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 430;
                final cardWidth = compact
                    ? (constraints.maxWidth - 10) / 2
                    : (constraints.maxWidth - 20) / 3;
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _summaryCard(
                      width: cardWidth,
                      title: 'Ventas',
                      value: _formatAmount(total),
                      icon: Icons.attach_money,
                    ),
                    _summaryCard(
                      width: cardWidth,
                      title: 'Pedidos',
                      value: '${orders.length}',
                      icon: Icons.receipt_long_outlined,
                    ),
                    _summaryCard(
                      width: cardWidth,
                      title: 'Promedio',
                      value: _formatAmount(average),
                      icon: Icons.bar_chart,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Periodo del reporte',
              style: TextStyle(color: _brand, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['Todo', 'Semanal', 'Mensual']
                  .map(
                    (period) => ChoiceChip(
                      label: Text(period),
                      selected: _selectedPeriod == period,
                      selectedColor: _brand,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      labelStyle: TextStyle(
                        color: _selectedPeriod == period
                            ? Colors.white
                            : _brand,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) =>
                          setState(() => _selectedPeriod = period),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tipo de pedido',
              style: TextStyle(color: _brand, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Todos', 'Mesas', 'Domicilios']
                    .map(
                      (type) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(type),
                          selected: _selectedType == type,
                          selectedColor: _brand,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          labelStyle: TextStyle(
                            color: _selectedType == type
                                ? Colors.white
                                : _brand,
                            fontWeight: FontWeight.w600,
                          ),
                          onSelected: (_) =>
                              setState(() => _selectedType = type),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            if (_error != null)
              Card(
                color: const Color(0xFFFFEFEC),
                child: ListTile(
                  leading: const Icon(Icons.error_outline, color: _brand),
                  title: Text(_error!),
                  trailing: TextButton(
                    onPressed: _loadOrders,
                    child: const Text('Reintentar'),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: CircularProgressIndicator(color: _brand)),
              )
            else if (orders.isEmpty)
              Padding(
                padding: const EdgeInsets.all(36),
                child: Column(
                  children: [
                    const Icon(
                      Icons.receipt_long_outlined,
                      size: 48,
                      color: Colors.black38,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _error == null
                          ? 'Todavía no hay pedidos para mostrar.'
                          : 'No se pudo cargar el reporte.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              )
            else
              ...orders.map(_orderCard),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard({
    required double width,
    required String title,
    required String value,
    required IconData icon,
  }) {
    return SizedBox(
      width: width,
      child: Card(
        margin: EdgeInsets.zero,
        color: Colors.white,
        elevation: 1,
        shadowColor: _brand.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: _brand.withValues(alpha: 0.07)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: _brand),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: _brand,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _orderCard(Map<String, dynamic> order) {
    final details = _details(order);
    final status =
        order['estado']?.toString().replaceAll('_', ' ') ?? 'pendiente';
    final user = order['usuario'];
    final customerName = user is Map ? user['nombre']?.toString() : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      elevation: 1,
      shadowColor: _brand.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: _brand.withValues(alpha: 0.07)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt_long_outlined, color: _brand),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_orderTitle(order)} · Pedido #${order['id'] ?? '—'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                Text(
                  _formatAmount(_amount(order)),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _brand,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              [
                _dateLabel(order),
                if (customerName != null && customerName.isNotEmpty)
                  'Atendido por: $customerName',
                'Estado: $status',
              ].join(' · '),
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            if (details.isNotEmpty) ...[
              const Divider(height: 20),
              ...details.take(4).map((detail) {
                final product = detail['producto'];
                final name = product is Map
                    ? product['nombre']?.toString() ?? 'Producto'
                    : 'Producto';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '${detail['cantidad'] ?? 0} × $name',
                    style: const TextStyle(fontSize: 13),
                  ),
                );
              }),
              if (details.length > 4)
                Text(
                  'Y ${details.length - 4} productos más',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
