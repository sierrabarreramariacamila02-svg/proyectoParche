import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../components/customer_bottom_navigation.dart';
import '../models/producto_model.dart';
import '../services/cart_service.dart';
import 'buscar.dart';
import 'domicilio.dart';
import 'pedidos.dart';

class Carrito extends StatefulWidget {
  const Carrito({super.key});

  static List<Map<String, dynamic>> itemsMemoria = [];

  static void agregarItem(Map<String, dynamic> nuevoItem) {
    int index = itemsMemoria.indexWhere(
      (item) =>
          item["nombre"] == nuevoItem["nombre"] &&
          item["acompanamiento"] == nuevoItem["acompanamiento"] &&
          item["bebida"] == nuevoItem["bebida"] &&
          item["sinCebolla"] == nuevoItem["sinCebolla"] &&
          item["sinLechuga"] == nuevoItem["sinLechuga"],
    );

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
  static const double _costoDomicilio = 8000;

  Future<void> _confirmarPedido() async {
    final cart = CartService.instance;
    if (cart.isEmpty) return;
    final creado = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const DomicilioPantalla()));
    if (creado == true && mounted) {
      // Pedido enviado: lo llevamos a Mis pedidos para que pueda seguirlo
      await Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const Pedidos()));
    }
  }

  String _formatearPrecio(double precio) => precio
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.');

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
          const delivery = _costoDomicilio;
          final total = cart.subtotal + delivery;
          if (cart.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.barraHome.withValues(alpha: 0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          color: AppColors.inputBackground,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.shopping_bag_outlined,
                          size: 42,
                          color: AppColors.barraHome,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Tu carrito está vacío',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.barraHome,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Explora el menú y agrega algo delicioso.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const Buscar()),
                        ),
                        icon: const Icon(Icons.search),
                        label: const Text('Buscar productos'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.barraHome,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ],
                  ),
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
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.barraHome.withValues(alpha: 0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: double.infinity,
                              child: Text(
                                '¡Pide tu domicilio!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.barraHome,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const SizedBox(
                              width: double.infinity,
                              child: Text(
                                'Recibe tu pedido en la dirección que indiques.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.barraHome,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 10,
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.delivery_dining,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Domicilio',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
                  color: Colors.white,
                  child: Column(
                    children: [
                      _totalRow('Subtotal', cart.subtotal),
                      _totalRow('Domicilio', delivery),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(height: 1),
                      ),
                      _totalRow('Total', total, destacado: true),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _confirmarPedido,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonOrange,
                            foregroundColor: Colors.white,
                            elevation: 1,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Text('Continuar con domicilio'),
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
      floatingActionButton: const CustomerCartButton(selectedIndex: 4),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const CustomerBottomNavigation(selectedIndex: 4),
    );
  }

  Widget _cartItem(CartLine line) {
    final ProductoModel product = line.product;
    final int quantity = line.quantity;
    return Card(
      color: const Color(0xFFFFF8F3),
      elevation: 1,
      shadowColor: AppColors.barraHome.withValues(alpha: 0.12),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.barraHome.withValues(alpha: 0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 58,
                height: 58,
                child: product.imagenUrl.isEmpty
                    ? const ColoredBox(
                        color: AppColors.inputBackground,
                        child: Icon(Icons.fastfood, color: AppColors.barraHome),
                      )
                    : Image.network(
                        product.imagenUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const ColoredBox(
                          color: AppColors.inputBackground,
                          child: Icon(
                            Icons.fastfood,
                            color: AppColors.barraHome,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.nombre,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${_formatearPrecio(product.precio)} × $quantity',
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${_formatearPrecio(product.precio * quantity)}',
                    style: const TextStyle(
                      color: AppColors.barraHome,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.barraHome.withValues(alpha: 0.12),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _quantityButton(
                    icon: Icons.remove,
                    onPressed: () => CartService.instance.setQuantity(
                      product.id,
                      quantity - 1,
                    ),
                  ),
                  Text(
                    '$quantity',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  _quantityButton(
                    icon: Icons.add,
                    onPressed: () => CartService.instance.setQuantity(
                      product.id,
                      quantity + 1,
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

  Widget _quantityButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 34, minHeight: 38),
      onPressed: onPressed,
      color: AppColors.barraHome,
      icon: Icon(icon, size: 18),
    );
  }

  Widget _totalRow(
    String label,
    double value, {
    bool destacado = false,
    bool gratis = false,
  }) {
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
          Text(
            gratis ? 'GRATIS' : '\$${_formatearPrecio(value)} COP',
            style: style,
          ),
        ],
      ),
    );
  }
}
