import 'package:elparchee/components/admin_banner_list_page.dart';
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
    Navigator.pop(context);
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/administracion',
      (route) => false,
    );
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
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminProductListPage(),
                    ),
                  );
                }),

                _item(Icons.star_outline, 'Platos destacados', () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminDestacadosPage(),
                    ),
                  );
                }),

                // --- 2. OPCIÓN DE BANNERS / PROMOCIONES CONECTADA ---
                _item(Icons.image_outlined, 'Banners y Promociones', () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminBannerListPage(),
                    ),
                  );
                }),

                _item(Icons.people_alt_outlined, 'Usuarios', () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminUserListPage(),
                    ),
                  );
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
