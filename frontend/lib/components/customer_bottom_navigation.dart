import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../pantallas/buscar.dart';
import '../pantallas/carrito.dart';
import '../pantallas/pedidos.dart';
import '../pantallas/perfil.dart';
import '../components/productos.dart';
import '../services/cart_service.dart';

class CustomerBottomNavigation extends StatelessWidget {
  final int selectedIndex;

  const CustomerBottomNavigation({super.key, required this.selectedIndex});

  void _open(BuildContext context, int index) {
    if (index == selectedIndex) return;
    final Widget page = switch (index) {
      0 => const Productos(),
      1 => const Buscar(),
      2 => const Pedidos(),
      3 => const Perfil(),
      4 => const Carrito(),
      _ => const Productos(),
    };
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.barraInferior,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _button(context, 0, Icons.home_outlined, 'Inicio'),
              _button(context, 1, Icons.search, 'Buscar'),
              _button(context, 2, Icons.receipt_long_outlined, 'Pedidos'),
              _button(context, 3, Icons.person_outline, 'Perfil'),
              AnimatedBuilder(
                animation: CartService.instance,
                builder: (context, _) => Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      tooltip: 'Carrito',
                      onPressed: () => _open(context, 4),
                      icon: Icon(
                        Icons.shopping_cart_outlined,
                        color: selectedIndex == 4
                            ? AppColors.barraHome
                            : Colors.brown,
                      ),
                    ),
                    if (CartService.instance.itemCount > 0)
                      Positioned(
                        right: 3,
                        top: 2,
                        child: CircleAvatar(
                          radius: 9,
                          backgroundColor: AppColors.buttonOrange,
                          child: Text(
                            '${CartService.instance.itemCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _button(
    BuildContext context,
    int index,
    IconData icon,
    String tooltip,
  ) {
    return IconButton(
      tooltip: tooltip,
      onPressed: () => _open(context, index),
      icon: Icon(
        icon,
        color: selectedIndex == index ? AppColors.barraHome : Colors.brown,
      ),
    );
  }
}
