import 'package:elparchee/services/adminUserService.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/admin_drawer.dart';
import '../models/user_model.dart';
import 'package:elparchee/app_colors.dart';

class AdminUserListPage extends StatefulWidget {
  const AdminUserListPage({super.key});
  @override
  State<AdminUserListPage> createState() => _AdminUserListPageState();
}

class _AdminUserListPageState extends State<AdminUserListPage> {
  static const Color brand = AppColors.barraHome;
  final _userService = AdminUserService();
  late Future<List<UserModel>> _futureUsuarios;
  String _adminName = '', _adminEmail = '';
  final _roles = [
    'pendiente',
    'mesero',
    'cocinero',
    'domiciliario',
    'administrador',
  ];

  @override
  void initState() {
    super.initState();
    _reload();
    _loadAdminInfo();
  }

  void _reload() {
    setState(() {
      _futureUsuarios = _userService.obtenerUsuarios();
    });
  }

  Future<void> _loadAdminInfo() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _adminName = prefs.getString('user_name') ?? 'Administrador';
        _adminEmail = prefs.getString('user_email') ?? '';
      });
    }
  }

  void _snack(String msg, [Color bg = AppColors.buttonOrange]) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: bg));
  }

  Future<void> _actualizarRol(UserModel user, String nuevoRol) async {
    final userId = user.id;
    if (userId == null || userId.isEmpty) {
      _snack(
        'No se encontró el identificador del usuario.',
        AppColors.barraHome,
      );
      return;
    }
    try {
      await _userService.cambiarRol(userId, nuevoRol);
      if (!mounted) return;
      _reload();
      _snack('Rol de ${user.nombre} actualizado a $nuevoRol');
    } catch (e) {
      if (mounted) {
        _snack(e.toString().replaceAll('Exception: ', ''), AppColors.barraHome);
      }
    }
  }

  void _mostrarEditorRol(UserModel user) {
    String rolSeleccionado = _roles.contains(user.rol) ? user.rol : 'pendiente';
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: const Text('Editar rol de usuario'),
          content: DropdownButtonFormField<String>(
            initialValue: rolSeleccionado,
            decoration: const InputDecoration(
              labelText: 'Rol',
              border: OutlineInputBorder(),
            ),
            items: _roles
                .map(
                  (rol) => DropdownMenuItem(
                    value: rol,
                    child: Text(rol.toUpperCase()),
                  ),
                )
                .toList(),
            onChanged: (rol) {
              if (rol != null) setSt(() => rolSeleccionado = rol);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: brand),
              onPressed: () {
                Navigator.pop(ctx);
                if (rolSeleccionado != user.rol) {
                  _actualizarRol(user, rolSeleccionado);
                }
              },
              child: const Text(
                'Guardar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F4F0),
      appBar: AppBar(
        title: const Text(
          'Gestión de Usuarios y Roles',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: brand,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: AdminDrawer(adminName: _adminName, adminEmail: _adminEmail),
      // Botón flotante agregado en la parte inferior derecha
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: brand,
        onPressed: () => _mostrarEditorRol,
        tooltip: 'Editar rol de usuario',

        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Agregar',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        color: brand,
        onRefresh: () async => _reload(),
        child: FutureBuilder<List<UserModel>>(
          future: _futureUsuarios,
          builder: (context, snapshot) {
           if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: brand));
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}'.replaceAll('Exception: ', ''),
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            final usuarios = snapshot.data ?? [];
            if (usuarios.isEmpty) {
              return const Center(child: Text('No hay usuarios registrados.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: usuarios.length,
              itemBuilder: (context, i) {
                final user = usuarios[i];
                final rolActual = _roles.contains(user.rol)
                    ? user.rol
                    : 'pendiente';

                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Stack(
                    children: [
                      ListTile(
                        title: Text(
                          user.nombre.isEmpty ? 'Sin nombre' : user.nombre,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          'Correo: ${user.email}\nTel: ${user.telefono}\nRol actual: $rolActual',
                        ),
                        isThreeLine: true,
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: TextButton.icon(
                          style: TextButton.styleFrom(foregroundColor: brand),
                          icon: const Icon(Icons.edit_outlined, size: 14),
                          label: const Text(
                            'Editar',
                            style: TextStyle(fontSize: 11),
                          ),
                          onPressed: () => _mostrarEditorRol(
                            user,
                          ), // o _mostrarFormularioUsuario(user: user) si usas el unificado
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
