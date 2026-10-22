import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/admin_drawer.dart';
import '../components/product_form_sheet.dart';
import '../models/producto_model.dart';
import '../services/admin_producto_service.dart';
import '../services/producto_service.dart';
import 'package:elparchee/app_colors.dart';

Future<bool> confirmarEliminacion(BuildContext context, String name) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Eliminar producto'),
      content: Text('¿Eliminar "$name"? Esta acción no se puede deshacer.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );
  return ok ?? false;
}

class AdminProductListPage extends StatefulWidget {
  const AdminProductListPage({super.key});

  @override
  State<AdminProductListPage> createState() => _AdminProductListPageState();
}

class _AdminProductListPageState extends State<AdminProductListPage> {
  static const Color brand = AppColors.barraHome;

  final ProductoService _productoService = ProductoService();
  late Future<List<ProductoModel>> _future;
  String _adminName = '';
  String _adminEmail = '';
  
  bool _huboCambios = false;

  @override
  void initState() {
    super.initState();
    _future = _productoService.obtenerProductos();
    _loadAdmin();
  }

  Future<void> _loadAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? 'Administrador';
    final email = prefs.getString('user_email') ?? '';

    if (!mounted) return;

    setState(() {
      _adminName = name;
      _adminEmail = email;
    });
  }

  void _reload() {
    setState(() {
      _future = _productoService.obtenerProductos();
      _huboCambios = true;
    });
  }

  void _snack(String msg, {Color color = AppColors.barraHome}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  Future<void> _openForm({ProductoModel? producto}) async {
    final saved = await ProductFormSheet.abrir(context, producto: producto);
    if (!saved || !mounted) return;
    _reload();
    _snack(producto == null ? 'Producto creado' : 'Cambios guardados');
  }

  Future<void> _delete(ProductoModel p) async {
    if (!await confirmarEliminacion(context, p.nombre) || !mounted) return;
    try {
      await AdminProductService.eliminarProductos(p.id);
      if (!mounted) return;
      _reload();
      _snack('"${p.nombre}" eliminado');
    } catch (e) {
      if (mounted) {
        _snack(
          e.toString().replaceAll('Exception: ', ''),
          color: AppColors.barraHome,
        );
      }
    }
  }

  Widget _thumb(String? url) {
    if (url == null || url.isEmpty) {
      return Container(
        color: AppColors.inputBackground,
        child: const Icon(Icons.production_quantity_limits, color: brand),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stack) =>
          const Icon(Icons.broken_image, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _huboCambios);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'Panel de administración',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: brand,
          iconTheme: const IconThemeData(color: Colors.white),
          // SE ELIMINÓ EL 'leading' MANUAL PARA QUE APAREZCA EL BOTÓN DEL DRAWER AUTOMÁTICAMENTE
        ),
        drawer: AdminDrawer(adminName: _adminName, adminEmail: _adminEmail),
        floatingActionButton: FloatingActionButton(
          backgroundColor: brand,
          foregroundColor: Colors.white,
          tooltip: 'Nuevo producto',
          onPressed: () => _openForm(),
          child: const Icon(Icons.add),
        ),
        body: RefreshIndicator(
          color: brand,
          onRefresh: () async => _reload(),
          child: FutureBuilder<List<ProductoModel>>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: brand),
                );
              }

              final items = snap.data ?? [];
              if (snap.hasError || items.isEmpty) {
                return ListView(
                  children: [
                    const SizedBox(height: 160),
                    Center(
                      child: Text(
                        snap.hasError
                            ? 'Error: ${snap.error}'.replaceAll('Exception: ', '')
                            : 'No hay productos registrados.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),
                  ],
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final p = items[i];
                  return Card(
                    color: AppColors.inputBackground,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: _thumb(p.imagenUrl),
                        ),
                      ),
                      title: Text(
                        p.nombre.isEmpty ? 'Sin nombre' : p.nombre,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '\$${p.precio.toStringAsFixed(2)}',
                        style: const TextStyle(color: brand),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Editar',
                            icon: const Icon(Icons.edit, color: brand),
                            onPressed: () => _openForm(producto: p),
                          ),
                          IconButton(
                            tooltip: 'Eliminar',
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AppColors.barraHome,
                            ),
                            onPressed: () => _delete(p),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}