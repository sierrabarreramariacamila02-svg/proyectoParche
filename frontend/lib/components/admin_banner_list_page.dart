import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/admin_drawer.dart';
import '../models/banner_model.dart';
import '../services/banner_service.dart';
import 'package:elparchee/app_colors.dart';

Future<bool> confirmarEliminacionBanner(BuildContext context) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Eliminar banner'),
      content: const Text('¿Estás seguro de eliminar esta promoción del carrusel?'),
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

class AdminBannerListPage extends StatefulWidget {
  const AdminBannerListPage({super.key});

  @override
  State<AdminBannerListPage> createState() => _AdminBannerListPageState();
}

class _AdminBannerListPageState extends State<AdminBannerListPage> {
  static const Color brand = AppColors.barraHome;

  final BannerService _bannerService = BannerService();
  late Future<List<BannerModel>> _future;
  String _adminName = '';
  String _adminEmail = '';
  bool _subiendo = false;

  @override
  void initState() {
    super.initState();
    _future = _bannerService.obtenerBanners();
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
      _future = _bannerService.obtenerBanners();
    });
  }

  void _snack(String msg, {Color color = AppColors.barraHome}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  // Seleccionar imagen de la galería y subirla directamente
  Future<void> _seleccionarYSubirBanner() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    setState(() => _subiendo = true);

    try {
      await _bannerService.crearBanner(pickedFile);
      if (!mounted) return;
      _reload();
      _snack('Banner subido con éxito al carrusel');
    } catch (e) {
      if (!mounted) return;
      _snack(e.toString().replaceAll('Exception: ', ''), color: Colors.red);
    } finally {
      if (mounted) setState(() => _subiendo = false);
    }
  }

  Future<void> _delete(BannerModel banner) async {
    if (!await confirmarEliminacionBanner(context) || !mounted) return;
    try {
      await _bannerService.eliminarBanner(banner.id);
      if (!mounted) return;
      _reload();
      _snack('Banner eliminado correctamente');
    } catch (e) {
      if (mounted) {
        _snack(e.toString().replaceAll('Exception: ', ''), color: Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Gestión de Banners',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: brand,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: AdminDrawer(adminName: _adminName, adminEmail: _adminEmail),
      floatingActionButton: FloatingActionButton(
        backgroundColor: brand,
        foregroundColor: Colors.white,
        tooltip: 'Subir nuevo banner',
        onPressed: _subiendo ? null : _seleccionarYSubirBanner,
        child: _subiendo
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.add_photo_alternate),
      ),
      body: RefreshIndicator(
        color: brand,
        onRefresh: () async => _reload(),
        child: FutureBuilder<List<BannerModel>>(
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
                          : 'No hay banners activos en el carrusel.',
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
                final banner = items[i];
                return Card(
                  color: AppColors.inputBackground,
                  margin: const EdgeInsets.only(bottom: 12),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Imagen previa del Banner en el carrusel
                      SizedBox(
                        height: 150,
                        child: Image.network(
                          banner.imagenUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) => const Center(
                            child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Banner #${banner.id}',
                              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
                            ),
                            IconButton(
                              tooltip: 'Eliminar banner',
                              icon: const Icon(Icons.delete_outline, color: AppColors.barraHome),
                              onPressed: () => _delete(banner),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}