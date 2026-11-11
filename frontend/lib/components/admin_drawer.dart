import 'package:elparchee/components/admin_banner_list_page.dart';
import 'package:elparchee/components/inventario.dart';
import 'package:elparchee/components/admin_sales_report_page.dart';
import 'package:elparchee/components/admin_domicilios_page.dart';
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
      backgroundColor: AppColors.background,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(18, 28, 16, 20),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_colorPrincipal, Color(0xFFB63D24)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white,
                        child: Text(
                          initial,
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: _colorPrincipal,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              adminName.isNotEmpty
                                  ? adminName
                                  : 'Administrador',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              adminEmail.isNotEmpty
                                  ? adminEmail
                                  : 'Sin correo registrado',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.82),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                _item(Icons.point_of_sale_outlined, 'Reporte de ventas', () {
                  _openPage(context, const AdminSalesReportPage());
                }),
                _item(Icons.delivery_dining_outlined, 'Domiciliarios', () {
                  _openPage(context, const AdminDeliveriesPage());
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
    final itemColor = color ?? _colorPrincipal;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(15),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: itemColor.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: itemColor, size: 21),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: color ?? Colors.black87,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
