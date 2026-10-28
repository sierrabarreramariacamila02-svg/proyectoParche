import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../api_config.dart';
import '../models/producto_model.dart';

class ProductoService {
  Future<List<ProductoModel>> obtenerProductos({String? categoria}) async {
    final baseUri = Uri.parse('${ApiConfig.baseUrl}/productos');
    final uri = categoria != null &&
            categoria.trim().isNotEmpty &&
            categoria != 'Todos'
        ? baseUri.replace(queryParameters: {'categoria': categoria})
        : baseUri;
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString('jwt_token') ?? '';
    final headers = <String, String>{...ApiConfig.headers};
    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final response = await http.get(uri, headers: headers);
      final contentType = response.headers['content-type'] ?? '';

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is! List) {
          throw Exception('El servidor devolvió un catálogo con formato inválido.');
        }
        return decoded
            .map((item) => ProductoModel.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ))
            .toList();
      }

      if (contentType.contains('application/json')) {
        final error = jsonDecode(response.body);
        throw Exception(
          error['message'] ?? error['error'] ?? 'Error al cargar productos',
        );
      }
      throw Exception('Error del servidor (Código ${response.statusCode})');
    } catch (error) {
      throw Exception(error.toString().replaceAll('Exception: ', ''));
    }
  }
}
