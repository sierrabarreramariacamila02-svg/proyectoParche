class BannerModel {
  final dynamic id;
  final String imagenUrl;
  final String descripcion;

  BannerModel({
    required this.id,
    required this.imagenUrl,
    this.descripcion = '',
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'],
      imagenUrl: json['imagen_url'] ?? '',
      descripcion: json['descripcion'] ?? '',
    );
  }
}
