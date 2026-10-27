import 'package:flutter/material.dart';

/// 15000.0 -> "$15,000" (mismo formato que tenías en las listas manuales)
String formatearPrecio(double precio) {
  final entero = precio.round().toString();
  final conMiles = entero.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return '\$$conMiles';
}

/// Muestra la foto del producto; si no tiene (o falla), muestra el icono de antes.
class ImagenProducto extends StatelessWidget {
  final String url;
  final IconData icono;
  final double size;

  const ImagenProducto({
    super.key,
    required this.url,
    required this.icono,
    this.size = 50,
  });

  @override
  Widget build(BuildContext context) {
    final respaldo = Icon(icono, size: size, color: Colors.orange);
    if (url.isEmpty) return respaldo;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        url,
        width: size + 15,
        height: size + 15,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => respaldo,
      ),
    );
  }
}