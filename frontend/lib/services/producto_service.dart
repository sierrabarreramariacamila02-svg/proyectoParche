import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';
import '../models/producto_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductoService {
  // Obtener la lista de productos (para el Home o filtrados por categoría en el Menú)
  Future<List<ProductoModel>> obtenerProductos({String? categoria}) async {
    String endpoint = '${ApiConfig.baseUrl}/productos';

    // Si viene una categoría válida y no es 'Todos', la adjuntamos como parámetro
    if (categoria != null && categoria.trim().isNotEmpty && categoria != 'Todos') {
      endpoint += '?categoria=$categoria';
    }

    final url = Uri.parse(endpoint);

    // Obtener el token de autenticación guardado
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    try {
      final response = await http.get(
        url,
        headers: {
          ...ApiConfig.headers,
          'Authorization': 'Bearer $token',
        },
      );

      final contentType = response.headers['content-type'] ?? '';

      if (response.statusCode == 200) {
        final List<dynamic> datos = jsonDecode(response.body);
        return datos.map((item) => ProductoModel.fromJson(item)).toList();
      } else {
        if (contentType.contains('application/json')) {
          final errorData = jsonDecode(response.body);
          throw Exception(
            errorData['message'] ?? errorData['error'] ?? 'Error al cargar productos',
          );
        } else {
          throw Exception('Error del servidor (Código ${response.statusCode})');
        }
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}