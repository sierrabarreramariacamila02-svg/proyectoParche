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

  final AdminUserService _userService = AdminUserService();
  late Future<List<UserModel>> _futureUsuarios;
  String _adminName = '';
  String _adminEmail = '';

  @override
  void initState() {
    super.initState();
    _futureUsuarios = _userService.obtenerUsuarios();
    _loadAdminInfo();
  }

  Future<void> _loadAdminInfo() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _adminName = prefs.getString('user_name') ?? 'Administrador';
      _adminEmail = prefs.getString('user_email') ?? '';
    });
  }

  void _reload() {
    setState(() {
      _futureUsuarios = _userService.obtenerUsuarios();
    });
  }

  void _snack(
    String msg, {
    Color backgroundColor = AppColors.buttonOrange,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: backgroundColor),
    );
  }

  Future<void> _actualizarRol(UserModel usuario, String nuevoRol) async {
    try {
      await _userService.cambiarRol(int.parse(usuario.id.toString()), nuevoRol);
      if (!mounted) return;
      _reload();
      _snack('Rol de ${usuario.nombre} actualizado a $nuevoRol');
    } catch (e) {
      if (mounted) {
        _snack(
          e.toString().replaceAll('Exception: ', ''),
          backgroundColor: AppColors.barraHome,
        );
      }
    }
  }

  @override
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
              return ListView(
                children: [
                  const SizedBox(height: 160),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Error: ${snapshot.error}'.replaceAll('Exception: ', ''),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              );
            }

            final usuarios = snapshot.data ?? [];
            if (usuarios.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 160),
                  Center(
                    child: Text('No hay usuarios registrados.',
                        style: TextStyle(color: Colors.black54)),
                  ),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: usuarios.length,
              itemBuilder: (context, index) {
                final user = usuarios[index];
                const rolesDisponibles = [
                  'pendiente',
                  'mesero',
                  'cocinero',
                  'domiciliario',
                  'administrador'
                ];

                String rolActual = rolesDisponibles.contains(user.rol)
                    ? user.rol
                    : 'pendiente';

                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(
                      user.nombre.isEmpty ? 'Sin nombre' : user.nombre,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Correo: ${user.email}\nTel: ${user.telefono}\nRol actual: $rolActual',
                    ),
                    isThreeLine: true,
                    trailing: DropdownButton<String>(
                      value: rolActual,
                      underline: const SizedBox(),
                      items: rolesDisponibles.map((String rol) {
                        return DropdownMenuItem<String>(
                          value: rol,
                          child: Text(
                            rol.toUpperCase(),
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        );
                      }).toList(),
                      onChanged: (nuevoRol) {
                        if (nuevoRol != null && nuevoRol != rolActual) {
                          _actualizarRol(user, nuevoRol);
                        }
                      },
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