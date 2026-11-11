import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:typed_data';

import '../app_colors.dart';
import '../components/customer_bottom_navigation.dart';
import 'inicioSesion.dart';
import '../services/profile_service.dart';

class Perfil extends StatefulWidget {
  const Perfil({super.key});

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  final ProfileService _profileService = ProfileService();
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();

  String _correo = '';
  String? _avatarUrl;
  XFile? _avatarSeleccionado;
  Uint8List? _avatarBytes;
  bool _cargando = true;
  bool _guardando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  Future<void> _cargarPerfil() async {
    try {
      final perfil = await _profileService.obtenerPerfil();
      if (!mounted) return;
      _nombreController.text = (perfil['nombre'] ?? '').toString();
      _telefonoController.text = (perfil['telefono'] ?? '').toString();
      _direccionController.text = (perfil['direccion'] ?? '').toString();
      setState(() {
        _correo = (perfil['email'] ?? '').toString();
        _avatarUrl = perfil['avatar']?.toString();
        _cargando = false;
        _error = null;
      });
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString('user_name', _nombreController.text);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _seleccionarFoto() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
      );
      if (image != null && mounted) {
        final bytes = await image.readAsBytes();
        if (!mounted) return;
        setState(() {
          _avatarSeleccionado = image;
          _avatarBytes = bytes;
        });
      }
    } catch (error) {
      if (!mounted) return;
      _mostrarMensaje('No se pudo seleccionar la imagen: $error', error: true);
    }
  }

  Future<void> _cerrarSesion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Quieres salir de tu cuenta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.barraHome),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    final preferences = await SharedPreferences.getInstance();
    await preferences.clear();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const Iniciosesion()),
      (_) => false,
    );
  }

  Future<void> _guardar() async {
    final nombre = _nombreController.text.trim();
    if (nombre.isEmpty) {
      _mostrarMensaje('El nombre es obligatorio.', error: true);
      return;
    }

    setState(() => _guardando = true);
    try {
      final perfil = await _profileService.actualizarPerfil(
        nombre: nombre,
        telefono: _telefonoController.text.trim(),
        direccion: _direccionController.text.trim(),
        avatar: _avatarSeleccionado,
      );
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(
        'user_name',
        (perfil['nombre'] ?? nombre).toString(),
      );
      if (!mounted) return;
      setState(() {
        _avatarUrl = perfil['avatar']?.toString() ?? _avatarUrl;
        _avatarSeleccionado = null;
        _avatarBytes = null;
        _guardando = false;
      });
      _mostrarMensaje('Perfil actualizado correctamente.');
    } catch (error) {
      if (!mounted) return;
      setState(() => _guardando = false);
      _mostrarMensaje(
        error.toString().replaceFirst('Exception: ', ''),
        error: true,
      );
    }
  }

  void _mostrarMensaje(String mensaje, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: error ? Colors.red.shade700 : Colors.green.shade700,
      ),
    );
  }

  ImageProvider? get _imagenPerfil {
    if (_avatarSeleccionado != null) {
      if (_avatarBytes != null) return MemoryImage(_avatarBytes!);
    }
    if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
      return NetworkImage(_avatarUrl!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mi perfil'),
        backgroundColor: AppColors.barraHome,
        foregroundColor: Colors.white,
      ),
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.barraHome),
            )
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.person_off_outlined,
                      size: 48,
                      color: AppColors.barraHome,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black54),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _cargando = true;
                          _error = null;
                        });
                        _cargarPerfil();
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.barraHome, Color(0xFFB63A25)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.barraHome.withValues(alpha: 0.18),
                        blurRadius: 16,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 54,
                              backgroundColor: AppColors.buttonOrange,
                              backgroundImage: _imagenPerfil,
                              child: _imagenPerfil == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: IconButton.filled(
                                onPressed: _seleccionarFoto,
                                tooltip: 'Cambiar foto',
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.barraHome,
                                  fixedSize: const Size(38, 38),
                                ),
                                icon: const Icon(Icons.camera_alt, size: 19),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _nombreController.text.isEmpty
                            ? 'Mi cuenta'
                            : _nombreController.text,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_correo.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          _correo,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 13,
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      TextButton.icon(
                        onPressed: _seleccionarFoto,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          visualDensity: VisualDensity.compact,
                        ),
                        icon: const Icon(
                          Icons.photo_library_outlined,
                          size: 18,
                        ),
                        label: const Text('Cambiar foto'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 10),
                  child: Text(
                    'Información personal',
                    style: TextStyle(
                      color: AppColors.barraHome,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.barraHome.withValues(alpha: 0.06),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _nombreController,
                        textCapitalization: TextCapitalization.words,
                        decoration: _decoracionCampo(
                          label: 'Nombre completo',
                          icon: Icons.person_outline,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        initialValue: _correo,
                        readOnly: true,
                        decoration: _decoracionCampo(
                          label: 'Correo electrónico',
                          icon: Icons.email_outlined,
                          helperText:
                              'El correo no se puede editar desde el perfil.',
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _telefonoController,
                        keyboardType: TextInputType.phone,
                        decoration: _decoracionCampo(
                          label: 'Teléfono',
                          icon: Icons.phone_outlined,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _direccionController,
                        maxLines: 2,
                        decoration: _decoracionCampo(
                          label: 'Dirección guardada',
                          icon: Icons.location_on_outlined,
                          alignLabelWithHint: true,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: _guardando ? null : _guardar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.barraHome,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                    icon: _guardando
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(
                      _guardando ? 'Guardando...' : 'Guardar cambios',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: _cerrarSesion,
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Cerrar sesión'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.barraHome,
                      side: BorderSide(
                        color: AppColors.barraHome.withValues(alpha: 0.35),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: const CustomerCartButton(selectedIndex: 3),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const CustomerBottomNavigation(selectedIndex: 3),
    );
  }

  InputDecoration _decoracionCampo({
    required String label,
    required IconData icon,
    String? helperText,
    bool alignLabelWithHint = false,
  }) {
    return InputDecoration(
      labelText: label,
      helperText: helperText,
      prefixIcon: Icon(icon, color: AppColors.barraHome),
      alignLabelWithHint: alignLabelWithHint,
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(
          color: AppColors.barraHome.withValues(alpha: 0.10),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: AppColors.barraHome, width: 1.4),
      ),
    );
  }
}
