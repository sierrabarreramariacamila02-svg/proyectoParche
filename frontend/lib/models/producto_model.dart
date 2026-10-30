class ProductoModel {
  final String id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String categoria;
  final String imagenUrl;
  final bool destacado;

  ProductoModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.categoria,
    required this.imagenUrl,
    this.destacado = false,
  });

  factory ProductoModel.fromJson(Map<String, dynamic> json) {
    return ProductoModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      precio: (json['precio'] as num?)?.toDouble() ?? 0.0,
      // Normaliza la categoría que viene del backend para que coincida con las opciones del formulario
      categoria: _mapearCategoria(json['categoria']?.toString()),
      // Prioriza 'imagen_url' (Supabase/Cloudinary) asegurando compatibilidad
      imagenUrl: json['imagen_url'] ?? json['imagenUrl'] ?? json['imagen'] ?? '',
      destacado: json['destacado'] == true,
    );
  }

  // Función auxiliar para estandarizar el texto de la categoría
  static String _mapearCategoria(String? cat) {
    if (cat == null || cat.trim().isEmpty) return 'Otros';
    final lower = cat.trim().toLowerCase();
    
    if (lower.contains('hamburguesa')) return 'Hamburguesas';
    if (lower.contains('perro')) return 'Perros calientes';
    if (lower.contains('salchipapa')) return 'Salchipapas';
    return 'Otros';
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'categoria': categoria,
      'imagen_url': imagenUrl,
      'destacado': destacado // Alineado con la columna de Supabase
    };
  }
}