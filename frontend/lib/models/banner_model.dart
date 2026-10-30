class BannerModel {
  final dynamic id;
  final String imagenUrl;

  BannerModel({
    required this.id,
    required this.imagenUrl,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'],
      imagenUrl: json['imagen_url'] ?? '',
    );
  }
}