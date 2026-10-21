import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:elparchee/app_colors.dart';


/// Recuadro de la foto del producto.
/// - Tocar: elegir de galería o cámara.
/// - Arrastrar la foto y pellizcar: acomodar el encuadre.
/// - Al guardar, el formulario sube el recorte con [capturarEncuadre].
class AdminImageSelector extends StatelessWidget {
  static const Color _brand = AppColors.buttonOrange;

  final File? imagen; // foto recién elegida (tiene prioridad)
  final String? imagenUrl; // foto actual del servidor (modo edición)
  final bool habilitado;
  final ValueChanged<File> onImagenSeleccionada;

  // Los crea el formulario: permiten recortar lo que se ve en el recuadro
  final GlobalKey capturaKey;
  final TransformationController encuadreController;

  const AdminImageSelector({
    super.key,
    required this.imagen,
    required this.onImagenSeleccionada,
    required this.capturaKey,
    required this.encuadreController,
    this.imagenUrl,
    this.habilitado = true,
  });

  /// true si el admin movió o hizo zoom a la foto
  static bool encuadreModificado(TransformationController c) =>
      c.value != Matrix4.identity();

  /// Convierte lo que se ve en el recuadro en un PNG listo para subir
  static Future<File> capturarEncuadre(GlobalKey capturaKey) async {
    final boundary =
        capturaKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final ui.Image img = await boundary.toImage(pixelRatio: 3.0);
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    final file = File(
      '${Directory.systemTemp.path}/producto_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(data!.buffer.asUint8List());
    return file;
  }

  bool get _tieneFoto =>
      imagen != null || (imagenUrl != null && imagenUrl!.isNotEmpty);

  Future<void> _elegirOrigen(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Seleccionar foto del producto',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: _brand),
              title: const Text('Elegir de la galería'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: _brand),
              title: const Text('Tomar con la cámara'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final foto = await ImagePicker().pickImage(source: source, imageQuality: 80);
    if (foto == null) return;

    encuadreController.value = Matrix4.identity(); // foto nueva: encuadre desde cero
    onImagenSeleccionada(File(foto.path));
  }

  Widget _botonFlotante(IconData icono, VoidCallback? onTap) {
    return Material(
      color: Colors.black54,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icono, size: 18, color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_tieneFoto) {
      return GestureDetector(
        onTap: habilitado ? () => _elegirOrigen(context) : null,
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300, width: 2),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_a_photo_rounded, size: 48, color: _brand),
              SizedBox(height: 8),
              Text('Toca para agregar la foto del producto',
                  style: TextStyle(color: Colors.black54)),
            ],
          ),
        ),
      );
    }

    final Widget foto = imagen != null
        ? Image.file(imagen!, fit: BoxFit.contain)
        : Image.network(
            imagenUrl!,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stack) => const Icon(
                Icons.broken_image_rounded, size: 40, color: Colors.grey),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _brand, width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Solo esta parte se captura al guardar (sin los botones)
                RepaintBoundary(
                  key: capturaKey,
                  child: Container(
                    color: Colors.white,
                    child: InteractiveViewer(
                      transformationController: encuadreController,
                      panEnabled: habilitado,
                      scaleEnabled: habilitado,
                      minScale: 0.5,
                      maxScale: 4,
                      // la foto se queda donde el admin la suelte
                      boundaryMargin: const EdgeInsets.all(double.infinity),
                      child: SizedBox.expand(child: foto),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    children: [
                      _botonFlotante(
                        Icons.center_focus_strong,
                        habilitado
                            ? () => encuadreController.value = Matrix4.identity()
                            : null,
                      ),
                      const SizedBox(width: 6),
                      _botonFlotante(
                        Icons.photo_camera,
                        habilitado ? () => _elegirOrigen(context) : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Arrastra la foto para acomodarla · pellizca para hacer zoom',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}