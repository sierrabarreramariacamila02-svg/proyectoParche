import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../components/customer_bottom_navigation.dart';
import '../models/producto_model.dart';
import '../services/cart_service.dart';
import '../services/restaurant_order_service.dart';
import 'buscar.dart';
import 'domicilio.dart';
import 'pedidos.dart';

class Carrito extends StatefulWidget {
  const Carrito({super.key});

  static List<Map<String, dynamic>> itemsMemoria = [];

  static void agregarItem(Map<String, dynamic> nuevoItem) {
    int index = itemsMemoria.indexWhere((item) =>
        item["nombre"] == nuevoItem["nombre"] &&
        item["acompanamiento"] == nuevoItem["acompanamiento"] &&
        item["bebida"] == nuevoItem["bebida"] &&
        item["sinCebolla"] == nuevoItem["sinCebolla"] &&
        item["sinLechuga"] == nuevoItem["sinLechuga"]);

    if (index >= 0) {
      itemsMemoria[index]["cant"] += nuevoItem["cant"];
    } else {
      itemsMemoria.add(nuevoItem);
    }
  }

  @override
  State<Carrito> createState() => _CarritoState();
}

class _CarritoState extends State<Carrito> {
  final RestaurantOrderService _orders = RestaurantOrderService();
  bool _recogerEnTienda = false;
  bool _procesando = false;
  static const double _costoDomicilio = 8000;

  Future<void> _confirmarPedido() async {
    final cart = CartService.instance;
    if (cart.isEmpty) return;
    if (_recogerEnTienda) {
      await _enviarPedido('recoger');
      return;
    }

    final creado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const DomicilioPantalla()),
    );
    if (creado == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pedido enviado. Puedes ver su estado en Mis pedidos.')),
      );
    }
  }

  Future<void> _enviarPedido(String tipo) async {
    setState(() => _procesando = true);
    try {
      await _orders.crearPedidoCliente(
        tipoPedido: tipo,
        productos: CartService.instance.toOrderItems(),
      );
      CartService.instance.clear();
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const Pedidos()),
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
      if (mounted) setState(() => _procesando = false);
    }
  }

  String _formatearPrecio(double precio) =>
      precio.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (match) => '.',
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Carrito'),
        backgroundColor: AppColors.barraHome,
        foregroundColor: Colors.white,
      ),
      body: AnimatedBuilder(
        animation: CartService.instance,
        builder: (context, _) {
          final cart = CartService.instance;
          final delivery = _recogerEnTienda ? 0.0 : _costoDomicilio;
          final total = cart.subtotal + delivery;
          if (cart.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.black38),
                    const SizedBox(height: 12),
                    const Text('Tu carrito está vacío'),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const Buscar()),
                      ),
                      icon: const Icon(Icons.search),
                      label: const Text('Buscar productos'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ...cart.items.map((line) => _cartItem(line)),
                    const SizedBox(height: 12),
                    const Text(
                      'Tipo de entrega',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(
                          value: false,
                          icon: Icon(Icons.delivery_dining),
                          label: Text('Domicilio'),
                        ),
                        ButtonSegment(
                          value: true,
                          icon: Icon(Icons.store),
                          label: Text('Recoger'),
                        ),
                      ],
                      selected: {_recogerEnTienda},
                      onSelectionChanged: (selection) =>
                          setState(() => _recogerEnTienda = selection.first),
                    ),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    children: [
                      _totalRow('Subtotal', cart.subtotal),
                      _totalRow(
                        'Domicilio',
                        delivery,
                        gratis: delivery == 0,
                      ),
                      const Divider(),
                      _totalRow('Total', total, destacado: true),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _procesando ? null : _confirmarPedido,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonOrange,
                            foregroundColor: Colors.white,
                          ),
                          child: _procesando
                              ? const CircularProgressIndicator()
                              : Text(
                                  _recogerEnTienda
                                      ? 'Confirmar pedido para recoger'
                                      : 'Continuar con domicilio',
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const CustomerBottomNavigation(selectedIndex: 4),
    );
  }

  Widget _cartItem(CartLine line) {
    final ProductoModel product = line.product;
    final int quantity = line.quantity;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: product.imagenUrl.isEmpty
            ? const CircleAvatar(child: Icon(Icons.fastfood))
            : CircleAvatar(backgroundImage: NetworkImage(product.imagenUrl)),
        title: Text(product.nombre),
        subtitle: Text(
          '\$${_formatearPrecio(product.precio)} × $quantity  ·  \$${_formatearPrecio(product.precio * quantity)}',
        ),
        trailing: SizedBox(
          width: 120,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => CartService.instance.setQuantity(
                  product.id,
                  quantity - 1,
                ),
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text('$quantity'),
              IconButton(
                onPressed: () => CartService.instance.setQuantity(
                  product.id,
                  quantity + 1,
                ),
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _totalRow(String label, double value, {bool destacado = false, bool gratis = false}) {
    final style = TextStyle(
      fontWeight: destacado ? FontWeight.bold : FontWeight.normal,
      fontSize: destacado ? 17 : 14,
      color: destacado ? AppColors.barraHome : null,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(gratis ? 'GRATIS' : '\$${_formatearPrecio(value)} COP', style: style),
        ],
      ),
    );
  }
}
