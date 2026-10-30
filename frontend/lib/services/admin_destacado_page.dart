import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:elparchee/app_colors.dart';
import '../components/admin_drawer.dart';
import '../components/destacado_form_sheet.dart';
import '../models/destacado_model.dart';
import '../services/destacado_service.dart';

class AdminDestacadosPage extends StatefulWidget {
  const AdminDestacadosPage({super.key});

  @override
  State<AdminDestacadosPage> createState() => _AdminDestacadosPageState();
}

class _AdminDestacadosPageState extends State<AdminDestacadosPage> {
  static const Color brand = AppColors.barraHome;

  late Future<List<DestacadoModel>> _future;
  String _adminName = '';
  String _adminEmail = '';

  @override
  void initState() {
    super.initState();
    _future = DestacadoService.obtener();
    _cargarAdmin();
  }

  Future<void> _cargarAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _adminName = prefs.getString('user_name') ?? 'Administrador';
      _adminEmail = prefs.getString('user_email') ?? '';
    });
  }

  void _reload() {
    setState(() {
      _future = DestacadoService.obtener();
    });
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: brand),
    );
  }

  String _formatoPrecio(double v) {
    final entero = v.round().toString();
    final conMiles = entero.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    return '\$$conMiles';
  }

  Future<void> _abrirFormulario({DestacadoModel? destacado}) async {
    final guardado = await DestacadoFormSheet.abrir(
      context,
      destacado: destacado,
    );
    if (!guardado || !mounted) return;
    _reload();
    _snack(destacado == null ? 'Plato destacado creado' : 'Cambios guardados');
  }

  Future<bool> _confirmarEliminar(String nombre) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar plato destacado'),
        content: Text('¿Eliminar "$nombre"? Esta acción no se puede deshacer.'),
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

  Future<void> _eliminar(DestacadoModel d) async {
    if (!await _confirmarEliminar(d.nombre) || !mounted) return;
    try {
      await DestacadoService.eliminar(d.id);
      if (!mounted) return;
      _reload();
      _snack('"${d.nombre}" eliminado');
    } catch (e) {
      if (mounted) _snack(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Widget _miniatura(String url) {
    if (url.isEmpty) {
      return Container(
        color: AppColors.inputBackground,
        child: const Icon(Icons.star_outline, color: brand),
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Platos destacados',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: brand,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: AdminDrawer(adminName: _adminName, adminEmail: _adminEmail),
      floatingActionButton: FloatingActionButton(
        backgroundColor: brand,
        foregroundColor: Colors.white,
        tooltip: 'Nuevo plato destacado',
        onPressed: () => _abrirFormulario(),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        color: brand,
        onRefresh: () async => _reload(),
        child: FutureBuilder<List<DestacadoModel>>(
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        snap.hasError
                            ? 'Error: ${snap.error}'.replaceAll('Exception: ', '')
                            : 'No hay platos destacados.\nToca + para agregar el primero.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final d = items[i];
                return Card(
                  color: AppColors.inputBackground,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: _miniatura(d.imagenUrl),
                      ),
                    ),
                    title: Text(
                      d.nombre.isEmpty ? 'Sin nombre' : d.nombre,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      _formatoPrecio(d.precio),
                      style: const TextStyle(color: brand),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Editar',
                          icon: const Icon(Icons.edit, color: brand),
                          onPressed: () => _abrirFormulario(destacado: d),
                        ),
                        IconButton(
                          tooltip: 'Eliminar',
                          icon: const Icon(Icons.delete_outline, color: brand),
                          onPressed: () => _eliminar(d),
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
    );
  }
}