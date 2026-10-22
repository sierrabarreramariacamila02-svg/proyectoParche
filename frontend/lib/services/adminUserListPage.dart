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

  // 📋 Modal para agregar un nuevo usuario con correo, nombre y rol
  void _mostrarFormularioAgregarUsuario() {
    final formKey = GlobalKey<FormState>();
    final nombreCtrl = TextEditingController();
    final correoCtrl = TextEditingController();
    String rolSeleccionado = 'pendiente';
    bool guardando = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFF6F4F0),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const Text(
                        'Agregar nuevo usuario',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: brand,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: nombreCtrl,
                        enabled: !guardando,
                        decoration: const InputDecoration(
                          labelText: 'Nombre',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Campo obligatorio'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: correoCtrl,
                        enabled: !guardando,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Correo electrónico',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Campo obligatorio';
                          }
                          if (!v.contains('@')) {
                            return 'Ingresa un correo válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
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
                        onChanged: guardando
                            ? null
                            : (nuevoRol) {
                                if (nuevoRol != null) {
                                  setModalState(
                                      () => rolSeleccionado = nuevoRol);
                                }
                              },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brand,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: guardando
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;
                                setModalState(() => guardando = true);
                                try {
                                  // TODO: Conecta aquí tu servicio para registrar o guardar el usuario en la BD.
                                  // Ejemplo: await _userService.crearUsuario(nombre: nombreCtrl.text.trim(), email: correoCtrl.text.trim(), rol: rolSeleccionado);
                                  
                                  await Future.delayed(
                                      const Duration(milliseconds: 600)); // Simulación de red

                                  if (mounted) {
                                    Navigator.pop(context);
                                    _reload();
                                    _snack('Usuario creado exitosamente');
                                  }
                                } catch (e) {
                                  setModalState(() => guardando = false);
                                  if (mounted) {
                                    _snack(
                                        e.toString().replaceAll('Exception: ', ''),
                                        brand);
                                  }
                                }
                              },
                        child: guardando
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'GUARDAR USUARIO',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Gestión de Usuarios y Roles',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: brand,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: AdminDrawer(adminName: _adminName, adminEmail: _adminEmail),
      // Botón flotante actualizado para desplegar el formulario de creación
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: brand,
        onPressed: _mostrarFormularioAgregarUsuario,
        tooltip: 'Agregar usuario',
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
                  color: AppColors.inputBackground,
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
                          onPressed: () => _mostrarEditorRol(user),
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