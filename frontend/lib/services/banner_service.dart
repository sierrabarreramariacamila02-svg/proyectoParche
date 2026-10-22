import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/banner_model.dart';

class BannerService {
  // Ajusta la URL base según tu entorno (emulador Android usa 10.0.2.2 o tu IP local)
  final String baseUrl = 'http://10.0.2.2:3000/api'; 

  Future<List<BannerModel>> obtenerBanners() async {
    final response = await http.get(Uri.parse('$baseUrl/banners'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => BannerModel.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener los banners');
    }
  }

  Future<void> crearBanner(XFile imagenFile) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/banners'));
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('imagen', imagenFile.path));

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 201) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['error'] ?? 'Error al subir el banner');
    }
  }

  Future<void> eliminarBanner(dynamic id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.delete(
      Uri.parse('$baseUrl/banners/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar el banner');
    }
  }
}