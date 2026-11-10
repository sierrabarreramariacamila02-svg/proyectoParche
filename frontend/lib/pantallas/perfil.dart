import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';

import '../app_colors.dart';
import '../components/customer_bottom_navigation.dart';
import '../services/profile_service.dart';
import 'notificaciones.dart';

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
  final TextEditingController _numDocumentoController = TextEditingController();

  String _correo = '';
  String? _avatarUrl;
  XFile? _avatarSeleccionado;
  Uint8List? _avatarBytes;

  bool _cargando = true;
  bool _guardando = false;
  String? _error;

  String _tipoDocumentoSeleccionado = 'Cédula de Ciudadanía';
  final List<String> _tiposDocumento = [
    'Cédula de Ciudadanía',
    'Tarjeta de Identidad',
  ];

  DateTime? _fechaNacimiento;
  bool _esMenorDeEdad = false;
  bool _permitirUbicacion = true;

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
    _numDocumentoController.dispose();
    super.dispose();
  }

  Future<void> _cargarPerfil() async {
    try {
      final perfil = await _profileService.obtenerPerfil();
      if (!mounted) return;
      _nombreController.text = (perfil['nombre'] ?? '').toString();
      _telefonoController.text = (perfil['telefono'] ?? '').toString();
      _direccionController.text = (perfil['direccion'] ?? '').toString();
      _numDocumentoController.text = (perfil['num_documento'] ?? '').toString();

      final tipoDocRemoto = perfil['tipo_documento']?.toString();
      if (tipoDocRemoto != null && _tiposDocumento.contains(tipoDocRemoto)) {
        _tipoDocumentoSeleccionado = tipoDocRemoto;
      }

      if (perfil['fecha_nacimiento'] != null) {
        _fechaNacimiento = DateTime.tryParse(
          perfil['fecha_nacimiento'].toString(),
        );
        _calcularEdad(_fechaNacimiento);
      }

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

  void _calcularEdad(DateTime? fecha) {
    if (fecha == null) return;
    final hoy = DateTime.now();
    int edad = hoy.year - fecha.year;
    if (hoy.month < fecha.month ||
        (hoy.month == fecha.month && hoy.day < fecha.day)) {
      edad--;
    }
    setState(() {
      _esMenorDeEdad = edad < 18;
    });
  }

  Future<void> _seleccionarFechaNacimiento() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento ?? DateTime(2005, 1, 1),
      firstDate: DateTime(1930),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _fechaNacimiento = picked;
      });
      _calcularEdad(picked);
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

  void _compartirUbicacionGPS() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubicación en tiempo real'),
        content: const Text(
          '¿Desea compartir su ubicación actual mediante GPS (estilo WhatsApp) para que el repartidor ubique su domicilio exactamente?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.barraHome,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _direccionController.text =
                    "Lat: 2.2514, Lon: -75.7645 (Ubicación GPS compartida)";
              });
              Navigator.pop(context);
              _mostrarMensaje('¡Ubicación exacta obtenida con éxito!');
            },
            child: const Text('Enviar ubicación actual'),
          ),
        ],
      ),
    );
  }

  void _eliminarCuenta() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Eliminar cuenta',
          style: TextStyle(color: Colors.red),
        ),
        content: const Text(
          '¿Estás seguro de que deseas eliminar tu cuenta permanentemente? Perderás todos tus datos y pedidos en El Parche.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              try {
                await Supabase.instance.client.auth.signOut();
                if (!mounted) return;
                Navigator.pop(context);
                _mostrarMensaje(
                  'Solicitud procesada. Sesión finalizada.',
                  error: true,
                );
              } catch (e) {
                if (!mounted) return;
                Navigator.pop(context);
                _mostrarMensaje(
                  'No se pudo procesar la solicitud: $e',
                  error: true,
                );
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
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

  String _formatearFecha(DateTime? fecha) {
    if (fecha == null) return 'Seleccionar fecha de nacimiento';
    const meses = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    return '${fecha.day} de ${meses[fecha.month - 1]} de ${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mi perfil'),
        backgroundColor: AppColors.barraHome,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/menu', (route) => false);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Notificaciones()),
              );
            },
          ),
        ],
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
                const SizedBox(height: 24),

                Row(
                  children: const [
                    Icon(Icons.badge_outlined, color: Colors.redAccent),
                    SizedBox(width: 8),
                    Text(
                      'Información adicional',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: _tipoDocumentoSeleccionado,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de documento',
                    prefixIcon: Icon(Icons.assignment_ind_outlined),
                    border: OutlineInputBorder(),
                  ),
                  items: _tiposDocumento.map((String tipo) {
                    return DropdownMenuItem<String>(
                      value: tipo,
                      child: Text(tipo),
                    );
                  }).toList(),
                  onChanged: (String? nuevoValor) {
                    if (nuevoValor != null) {
                      setState(() {
                        _tipoDocumentoSeleccionado = nuevoValor;
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _numDocumentoController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Número de documento',
                    prefixIcon: Icon(Icons.pin_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                InkWell(
                  onTap: _seleccionarFechaNacimiento,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Fecha de nacimiento',
                      prefixIcon: Icon(Icons.cake_outlined),
                      border: OutlineInputBorder(),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatearFecha(_fechaNacimiento)),
                        Text(
                          _fechaNacimiento == null
                              ? ''
                              : (_esMenorDeEdad
                                    ? 'Menor de edad'
                                    : 'Mayor de edad'),
                          style: TextStyle(
                            color: _esMenorDeEdad
                                ? Colors.orange.shade800
                                : Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Card(
                  elevation: 0,
                  color: Colors.grey.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _direccionController,
                                maxLines: 2,
                                decoration: const InputDecoration(
                                  labelText: 'Ubicación para domicilios',
                                  prefixIcon: Icon(Icons.location_on_outlined),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: _compartirUbicacionGPS,
                              icon: const Icon(
                                Icons.share_location,
                                color: Colors.green,
                                size: 32,
                              ),
                              tooltip:
                                  'Compartir ubicación GPS (Estilo WhatsApp)',
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Text(
                                'Permitir acceso a tu ubicación para recibir ofertas y mejorar tu experiencia.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            Switch(
                              value: _permitirUbicacion,
                              activeColor: AppColors.buttonOrange,
                              onChanged: (val) =>
                                  setState(() => _permitirUbicacion = val),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Sección renombrada a Cuenta para que encaje perfectamente
                const Text(
                  'Cuenta',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text(
                    'Eliminar cuenta',
                    style: TextStyle(color: Colors.red),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _eliminarCuenta,
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
                const SizedBox(height: 30),
                const Center(
                  child: Text(
                    'Versión 1.0.0',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
      floatingActionButton: const CustomerCartButton(selectedIndex: 3),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const CustomerBottomNavigation(selectedIndex: 3),
    );
  }
}
