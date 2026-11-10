import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  Future<void> _open(BuildContext context, int index) async {
    if (index == selectedIndex) return;
    final preferences = await SharedPreferences.getInstance();
    if (!context.mounted) return;
    final role = (preferences.getString('user_role') ?? '')
        .toLowerCase()
        .trim();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => _pageForIndex(
          index,
          isAdmin: role == 'admin' || role == 'administrador',
        ),
      ),
    );
  }

  static Widget _pageForIndex(int index, {bool isAdmin = false}) =>
      switch (index) {
        0 => Productos(isAdmin: isAdmin),
        1 => const Buscar(),
        2 => const Pedidos(),
        3 => const Perfil(),
        4 => const Carrito(),
        _ => const Productos(),
      };

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: const Color(0xFFF2D6BD),
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _button(context, 0, Icons.home, 'Inicio'),
            _button(context, 1, Icons.search, 'Buscar'),
            const SizedBox(width: 40),
            _button(context, 2, Icons.receipt_long, 'Pedidos'),
            _button(context, 3, Icons.person_outline, 'Perfil'),
          ],
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

class CustomerCartButton extends StatelessWidget {
  final int selectedIndex;

  const CustomerCartButton({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CartService.instance,
      builder: (context, _) => FloatingActionButton(
        tooltip: 'Carrito',
        backgroundColor: AppColors.buttonOrange,
        elevation: 4,
        shape: const CircleBorder(),
        onPressed: () {
          if (selectedIndex == 4) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => CustomerBottomNavigation._pageForIndex(4),
            ),
          );
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.shopping_cart, color: Colors.white),
            if (CartService.instance.itemCount > 0)
              Positioned(
                right: -9,
                top: -8,
                child: CircleAvatar(
                  radius: 9,
                  backgroundColor: AppColors.barraHome,
                  child: Text(
                    '${CartService.instance.itemCount}',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
