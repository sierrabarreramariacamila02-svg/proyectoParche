import 'dart:convert';

class OpcionExtraProducto {
  final String nombre;
  final double precio;

  const OpcionExtraProducto({required this.nombre, required this.precio});

  factory OpcionExtraProducto.fromDynamic(dynamic raw) {
    if (raw is Map) {
      return OpcionExtraProducto(
        nombre: (raw['nombre'] ?? '').toString().trim(),
        precio: double.tryParse((raw['precio'] ?? 0).toString()) ?? 0.0,
      );
    }
    return OpcionExtraProducto(nombre: raw.toString().trim(), precio: 0.0);
  }

  Map<String, dynamic> toJson() => {'nombre': nombre, 'precio': precio};
}

class ProductoModel {
  final String id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String categoria;
  final String imagenUrl;
  final bool destacado;
  final List<String> personalizaciones;
  final List<OpcionExtraProducto> acompanamientos;
  final List<OpcionExtraProducto> bebidas;

  ProductoModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.categoria,
    required this.imagenUrl,
    this.destacado = false,
    this.personalizaciones = const [],
    this.acompanamientos = const [],
    this.bebidas = const [],
  });

  factory ProductoModel.fromJson(Map<String, dynamic> json) {
    return ProductoModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      precio: (json['precio'] as num?)?.toDouble() ?? 0.0,
      categoria: _mapearCategoria(json['categoria']?.toString()),
      imagenUrl:
          json['imagen_url'] ?? json['imagenUrl'] ?? json['imagen'] ?? '',
      destacado: json['destacado'] == true,
      personalizaciones: _parsearPersonalizaciones(json['personalizaciones']),
      acompanamientos: _parsearExtras(json['acompanamientos']),
      bebidas: _parsearExtras(json['bebidas']),
    );
  }

  static List<String> _parsearPersonalizaciones(dynamic raw) {
    if (raw == null) return const [];
    dynamic data = raw;
    if (data is String && data.trim().startsWith('[')) {
      try {
        data = jsonDecode(data);
      } catch (_) {}
    }
    if (data is List) {
      return data
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    if (data is String && data.trim().isNotEmpty) {
      return data
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return const [];
  }

  static List<OpcionExtraProducto> _parsearExtras(dynamic raw) {
    if (raw == null) return const [];
    dynamic data = raw;
    if (data is String && data.trim().startsWith('[')) {
      try {
        data = jsonDecode(data);
      } catch (_) {}
    }
    if (data is List) {
      return data
          .map((e) => OpcionExtraProducto.fromDynamic(e))
          .where((e) => e.nombre.isNotEmpty)
          .toList();
    }
    return const [];
  }

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
      'destacado': destacado,
      'personalizaciones': personalizaciones,
      'acompanamientos': acompanamientos.map((e) => e.toJson()).toList(),
      'bebidas': bebidas.map((e) => e.toJson()).toList(),
    };
  }
}
