import 'package:elparchee/app_colors.dart';
import 'package:elparchee/pantallas/inicioSesion.dart';
import 'package:elparchee/services/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MeseroPerfilPage extends StatefulWidget {
  final String roleLabel;

  const MeseroPerfilPage({super.key, this.roleLabel = 'Mesero'});

  @override
  State<MeseroPerfilPage> createState() => _MeseroPerfilPageState();
}

class _MeseroPerfilPageState extends State<MeseroPerfilPage> {
  final ProfileService _profileService = ProfileService();
  Map<String, dynamic>? _profile;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final profile = await _profileService.obtenerPerfil();
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: Text(
          '¿Quieres salir de tu cuenta de ${widget.roleLabel.toLowerCase()}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.barraHome),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final preferences = await SharedPreferences.getInstance();
    await preferences.clear();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const Iniciosesion()),
      (_) => false,
    );
  }

  String _value(String key) {
    final value = _profile?[key]?.toString().trim() ?? '';
    return value.isEmpty ? 'No registrado' : value;
  }

  @override
  Widget build(BuildContext context) {
    final name = _profile?['nombre']?.toString() ?? widget.roleLabel;
    final avatar = _profile?['avatar']?.toString();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mi perfil'),
        backgroundColor: AppColors.barraHome,
        foregroundColor: Colors.white,
      ),
      body: _loading
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
                    Text(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _loadProfile,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: AppColors.inputBackground,
                          backgroundImage: avatar != null && avatar.isNotEmpty
                              ? NetworkImage(avatar)
                              : null,
                          child: avatar == null || avatar.isEmpty
                              ? const Icon(
                                  Icons.person,
                                  size: 52,
                                  color: AppColors.barraHome,
                                )
                              : null,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: AppColors.barraHome,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.roleLabel,
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _profileField(
                  Icons.person_outline,
                  'Nombre completo',
                  _value('nombre'),
                ),
                _profileField(
                  Icons.email_outlined,
                  'Correo electrónico',
                  _value('email'),
                ),
                _profileField(
                  Icons.phone_outlined,
                  'Teléfono',
                  _value('telefono'),
                ),
                _profileField(
                  Icons.location_on_outlined,
                  'Dirección',
                  _value('direccion'),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 50,
                  child: FilledButton.icon(
                    onPressed: _logout,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.barraHome,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text('Cerrar sesión'),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _profileField(IconData icon, String title, String value) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Icon(icon, color: AppColors.barraHome),
        title: Text(title, style: const TextStyle(fontSize: 12)),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class CocinaPerfilPage extends MeseroPerfilPage {
  const CocinaPerfilPage({super.key}) : super(roleLabel: 'Cocina');
}
