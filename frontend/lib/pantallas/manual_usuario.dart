import 'package:elparchee/app_colors.dart';
import 'package:flutter/material.dart';

/// Pantalla de Ayuda: muestra el manual de usuario de una vez.
/// Las páginas del manual están guardadas como imágenes en assets/manual/,
/// así funciona igual en Chrome, Android e iOS (sin lectores de PDF).
class ManualUsuario extends StatelessWidget {
  const ManualUsuario({super.key});

  static const int totalPaginas = 53;

  String _ruta(int i) =>
      'assets/manual/pagina-${(i + 1).toString().padLeft(2, '0')}.jpg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0),
      appBar: AppBar(
        backgroundColor: AppColors.barraHome,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Ayuda - Manual de usuario',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: InteractiveViewer(
        minScale: 1,
        maxScale: 4,
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: totalPaginas,
          itemBuilder: (context, i) => Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Card(
                margin: const EdgeInsets.only(bottom: 10),
                elevation: 2,
                child: Image.asset(
                  _ruta(i),
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'No se encontró ${_ruta(i)}.\nRevisa que la carpeta assets/manual/ esté en pubspec.yaml.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
