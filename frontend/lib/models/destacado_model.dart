import 'producto_model.dart';

class DestacadoModel {
  final String id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String imagenUrl;

  DestacadoModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.imagenUrl,
  });

  factory DestacadoModel.fromJson(Map<String, dynamic> json) {
    final precioCrudo = json['precio'];
    return DestacadoModel(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      precio: precioCrudo is num
          ? precioCrudo.toDouble()
          : double.tryParse(precioCrudo?.toString() ?? '') ?? 0,
      imagenUrl: json['imagen_url']?.toString() ?? '',
    );
  }

  /// Permite reutilizar la cuadrícula del home, que trabaja con ProductoModel
  ProductoModel toProducto() => ProductoModel(
        id: id,
        nombre: nombre,
        descripcion: descripcion,
        precio: precio,
        categoria: 'Destacados',
        imagenUrl: imagenUrl,
      );
}