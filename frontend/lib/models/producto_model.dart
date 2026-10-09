class ProductoModel {
  final String id;
  final String nombre;
  final String descripcion;
  final int precio;
  final String categoria;
  final String imagenUrl;

  ProductoModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.categoria,
    required this.imagenUrl,
  });

  factory ProductoModel.fromJson(Map<String, dynamic> json) {
    return ProductoModel(
      id: json['_id']?. toString() ?? json['id']?. toString() ?? '',
      nombre: json['nombre'] ??'',
      descripcion: json['descripcion'] ??'',
      precio: (json['precio'] as int?)?.toInt() ?? 0,
      categoria: json['categoria'] as String,
      imagenUrl: json['imagenUrl'] ?? json['imagen'] ?? json['imagen_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'categoria': categoria,
      if (imagenUrl != null) 'imagenUrl': imagenUrl,
      
    };
  }
}