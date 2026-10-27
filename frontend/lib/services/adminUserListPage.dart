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
  final _roles = ['pendiente', 'mesero', 'cocinero', 'domiciliario', 'admin'];

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

  String _etiquetaRol(String rol) =>
      rol == 'admin' ? 'ADMINISTRADOR' : rol.toUpperCase();

  String _rolNormalizado(String rol) =>
      rol.toLowerCase() == 'administrador' ? 'admin' : rol.toLowerCase();

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
    final rolActual = _rolNormalizado(user.rol);
    String rolSeleccionado = _roles.contains(rolActual)
        ? rolActual
        : 'pendiente';
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
                    child: Text(_etiquetaRol(rol)),
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
    String? errorGuardar;

    showModalBottomSheet<void>(
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
                                child: Text(_etiquetaRol(rol)),
                              ),
                            )
                            .toList(),
                        onChanged: guardando
                            ? null
                            : (nuevoRol) {
                                if (nuevoRol != null) {
                                  setModalState(
                                    () => rolSeleccionado = nuevoRol,
                                  );
                                }
                              },
                      ),
                      if (errorGuardar != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          errorGuardar!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ],
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
                                setModalState(() {
                                  guardando = true;
                                  errorGuardar = null;
                                });
                                try {
                                  final existentePromovido = await _userService
                                      .crearUsuario(
                                        nombre: nombreCtrl.text.trim(),
                                        email: correoCtrl.text.trim(),
                                        rol: rolSeleccionado,
                                      );

                                  if (mounted) {
                                    Navigator.of(this.context).pop();
                                    _reload();
                                    _snack(
                                      existentePromovido
                                          ? 'Usuario agregado al panel con el rol seleccionado.'
                                          : 'Usuario agregado. Podrá completar su registro con ese correo.',
                                    );
                                  }
                                } catch (e) {
                                  setModalState(() {
                                    guardando = false;
                                    errorGuardar = e.toString().replaceFirst(
                                      'Exception: ',
                                      '',
                                    );
                                  });
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
                                  color: Colors.white,
                                ),
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
    ).whenComplete(() {
      nombreCtrl.dispose();
      correoCtrl.dispose();
    });
  }

  Future<void> _eliminarUsuario(UserModel user) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar usuario'),
        content: Text(
          '¿Deseas eliminar a ${user.nombre}? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar != true || user.id == null || user.id!.isEmpty) return;

    try {
      await _userService.eliminarUsuario(user.id);
      if (!mounted) return;
      _reload();
      _snack('Usuario eliminado');
    } catch (e) {
      if (mounted) {
        _snack(e.toString().replaceAll('Exception: ', ''), brand);
      }
    }
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
              return const Center(
                child: CircularProgressIndicator(color: brand),
              );
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
                final rolNormalizado = _rolNormalizado(user.rol);
                final rolActual = _roles.contains(rolNormalizado)
                    ? _etiquetaRol(rolNormalizado)
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
                        bottom: 4,
                        right: 4,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                foregroundColor: brand,
                              ),
                              icon: const Icon(Icons.edit_outlined, size: 14),
                              label: const Text(
                                'Editar',
                                style: TextStyle(fontSize: 11),
                              ),
                              onPressed: () => _mostrarEditorRol(user),
                            ),
                            IconButton(
                              tooltip: 'Eliminar usuario',
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              onPressed: () => _eliminarUsuario(user),
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
