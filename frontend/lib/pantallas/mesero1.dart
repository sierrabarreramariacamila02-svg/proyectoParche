import 'dart:async';
import 'package:elparchee/app_colors.dart';
import 'package:elparchee/pantallas/mesero_perfil.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/restaurant_order_service.dart';
import 'meseroo2.dart';

class GestionMesas extends StatefulWidget {
  final bool adminMode;

  const GestionMesas({super.key, this.adminMode = false});

  @override
  State<GestionMesas> createState() => _GestionMesasState();
}

class _GestionMesasState extends State<GestionMesas> {
  static const _mesasPreferenceKey = 'mesero_numero_mesas';

  final RestaurantOrderService _orders = RestaurantOrderService();
  List<Map<String, dynamic>> _pedidos = [];
  final Set<String> _pedidosListosNotificados = {};
  int _numeroMesas = 4;
  String _nombre = 'Mesero';
  Timer? _timer;
  bool _cargando = true;
  bool _cargandoPedidos = false;
  bool _primeraCarga = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _inicializar();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      _cargarPedidos(silencioso: true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _inicializar() async {
    final preferences = await SharedPreferences.getInstance();
    final numeroMesas = preferences.getInt(_mesasPreferenceKey) ?? 4;
    if (!mounted) return;
    setState(() {
      _numeroMesas = numeroMesas < 4 ? 4 : numeroMesas;
      _nombre = preferences.getString('user_name') ?? 'Mesero';
    });
    await _cargarPedidos();
  }

  Future<void> _cargarPedidos({bool silencioso = false}) async {
    if (_cargandoPedidos) return;
    _cargandoPedidos = true;
    if (!silencioso) {
      setState(() {
        _cargando = true;
        _error = null;
      });
    }

    try {
      final pedidos = widget.adminMode
          ? await _orders.listarTodosLosPedidos()
          : await _orders.listarPedidosMesero();
      if (!mounted) return;
      final pedidosMesa = pedidos
          .where((pedido) => pedido['tipo_pedido'] == 'mesa')
          .toList();
      final listos = pedidosMesa
          .where((pedido) => pedido['estado']?.toString() == 'listo')
          .toList();
      final nuevosListos = _primeraCarga
          ? <Map<String, dynamic>>[]
          : listos
                .where(
                  (pedido) => !_pedidosListosNotificados.contains(
                    pedido['id']?.toString(),
                  ),
                )
                .toList();
      setState(() {
        _pedidos = pedidosMesa;
        _pedidosListosNotificados
          ..clear()
          ..addAll(listos.map((pedido) => pedido['id'].toString()));
        _primeraCarga = false;
        _error = null;
        _cargando = false;
      });
      if (nuevosListos.isNotEmpty && mounted) {
        final mesa = nuevosListos.first['numero_mesa']?.toString();
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                nuevosListos.length > 1
                    ? '${nuevosListos.length} pedidos están listos para entregar.'
                    : mesa == null
                    ? 'Un pedido está listo para entregar.'
                    : 'El pedido de la mesa $mesa está listo para entregar.',
              ),
              backgroundColor: Colors.green.shade800,
            ),
          );
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
        _cargando = false;
      });
    } finally {
      _cargandoPedidos = false;
    }
  }

  Future<void> _agregarMesa() async {
    final nuevoNumero = _numeroMesas + 1;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_mesasPreferenceKey, nuevoNumero);
    if (!mounted) return;
    setState(() => _numeroMesas = nuevoNumero);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Mesa $nuevoNumero agregada.')));
  }

  Future<void> _abrirMesa(int numeroMesa) async {
    final creado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => TomarPedidoScreen(numeroMesa: numeroMesa.toString()),
      ),
    );
    if (creado == true) {
      await _cargarPedidos();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pedido de la mesa $numeroMesa enviado a cocina.'),
        ),
      );
    }
  }

  Map<String, dynamic>? _pedidoActivo(int numeroMesa) {
    final deLaMesa = _pedidos.where(
      (pedido) =>
          pedido['numero_mesa']?.toString() == numeroMesa.toString() &&
          pedido['estado']?.toString() != 'entregado',
    );
    return deLaMesa.isEmpty ? null : deLaMesa.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.barraHome,
        foregroundColor: Colors.white,
        title: const Text(
          'Mesas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar mesas',
            onPressed: _cargando ? null : _cargarPedidos,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Mi perfil',
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const MeseroPerfilPage())),
            icon: const Icon(Icons.account_circle_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.barraHome,
        onRefresh: _cargarPedidos,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hola, $_nombre',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.barraHome,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Selecciona una mesa para tomar o revisar un pedido.',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
            if (_error != null)
              SliverToBoxAdapter(
                child: MaterialBanner(
                  content: Text(_error!),
                  leading: const Icon(Icons.error_outline),
                  actions: [
                    TextButton(
                      onPressed: _cargarPedidos,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            if (_cargando && _pedidos.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.barraHome),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                sliver: SliverLayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.crossAxisExtent;
                    final columns = width >= 900
                        ? 4
                        : width >= 600
                        ? 3
                        : 2;
                    return SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.08,
                      ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final numeroMesa = index + 1;
                        return _mesaCard(numeroMesa, _pedidoActivo(numeroMesa));
                      }, childCount: _numeroMesas),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _agregarMesa,
        backgroundColor: AppColors.primaryOrange,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Agregar mesa'),
      ),
    );
  }

  Widget _mesaCard(int numeroMesa, Map<String, dynamic>? pedido) {
    final estado = pedido?['estado']?.toString() ?? '';
    final estaLista = estado == 'listo';
    final estaOcupada = pedido != null;
    final colorEstado = estaLista
        ? Colors.green.shade700
        : estaOcupada
        ? AppColors.primaryOrange
        : Colors.black45;
    final etiquetaEstado = estaLista
        ? 'Pedido listo'
        : estaOcupada
        ? 'En preparación'
        : 'Disponible';

    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _abrirMesa(numeroMesa),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.table_restaurant_rounded,
                size: 38,
                color: colorEstado,
              ),
              const SizedBox(height: 8),
              Text(
                'Mesa $numeroMesa',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: colorEstado.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  etiquetaEstado,
                  style: TextStyle(
                    color: colorEstado,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (pedido != null)
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    'Pedido #${pedido['id']}',
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
