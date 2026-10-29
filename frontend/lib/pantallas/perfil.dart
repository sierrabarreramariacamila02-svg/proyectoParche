import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:typed_data';

import '../app_colors.dart';
import '../components/customer_bottom_navigation.dart';
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
      _mostrarMensaje(
        'No se pudo seleccionar la imagen: $error',
        error: true,
      );
    }
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
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
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
                  padding: const EdgeInsets.all(20),
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
                              icon: const Icon(Icons.camera_alt),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton.icon(
                        onPressed: _seleccionarFoto,
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Cambiar foto de perfil'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _nombreController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Nombre completo',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: _correo,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        prefixIcon: Icon(Icons.email_outlined),
                        helperText: 'El correo no se puede editar desde el perfil.',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _telefonoController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono',
                        prefixIcon: Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _direccionController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Dirección guardada',
                        prefixIcon: Icon(Icons.location_on_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _guardando ? null : _guardar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.barraHome,
                          foregroundColor: Colors.white,
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
                  ],
                ),
      bottomNavigationBar: const CustomerBottomNavigation(selectedIndex: 3),
    );
  }
} 
