import 'package:elparchee/components/admin_banner_list_page.dart';
import 'package:elparchee/components/inventario.dart';
import 'package:elparchee/pantallas/inicioSesion.dart';
import 'package:elparchee/services/adminUserListPage.dart';
import 'package:elparchee/services/admin_destacado_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:elparchee/app_colors.dart';
import '../pages/admin_product_list_page.dart';

class AdminDrawer extends StatelessWidget {
  static const Color _colorPrincipal = AppColors.barraHome;

  final String adminName;
  final String adminEmail;

  const AdminDrawer({
    super.key,
    required this.adminName,
    required this.adminEmail,
  });

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const Iniciosesion()),
      (route) => false,
    );
  }

  void _openHome(BuildContext context) {
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.pushNamedAndRemoveUntil('/administracion', (route) => false);
  }

  void _openPage(BuildContext context, Widget page) {
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final initial = adminName.isNotEmpty ? adminName[0].toUpperCase() : 'A';

    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  margin: EdgeInsets.zero,
                  decoration: const BoxDecoration(color: _colorPrincipal),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      initial,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: _colorPrincipal,
                      ),
                    ),
                  ),
                  accountName: Text(
                    adminName.isNotEmpty ? adminName : 'Administrador',
                  ),
                  accountEmail: Text(
                    adminEmail.isNotEmpty
                        ? adminEmail
                        : 'Sin correo registrado',
                  ),
                ),
                _item(Icons.home_outlined, 'Inicio (Productos)', () {
                  _openHome(context);
                }),
                _item(Icons.store, 'Administrar productos', () {
                  _openPage(context, const AdminProductListPage());
                }),
                _item(Icons.inventory_2_outlined, 'Inventario', () {
                  _openPage(context, const InventarioScreen());
                }),
                _item(Icons.star_outline, 'Platos destacados', () {
                  _openPage(context, const AdminDestacadosPage());
                }),
                _item(Icons.image_outlined, 'Banners y Promociones', () {
                  _openPage(context, const AdminBannerListPage());
                }),
                _item(Icons.people_alt_outlined, 'Usuarios', () {
                  _openPage(context, const AdminUserListPage());
                }),
              ],
            ),
          ),
          const Divider(height: 1),
          SafeArea(
            top: false,
            child: _item(
              Icons.logout_rounded,
              'Cerrar sesión',
              () => _logout(context),
              color: AppColors.barraHome,
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? _colorPrincipal),
      title: Text(title, style: TextStyle(color: color)),
      onTap: onTap,
    );
  }
}
