import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api_config.dart';
import '../models/user_model.dart';

class AdminUserService {
  // Método privado para obtener el token JWT guardado en SharedPreferences
  static Future<String?> _obtenerToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // Manejador centralizado de errores para las respuestas HTTP
  String _mensajeError(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      return (data['error'] ??
              data['message'] ??
              'Error del servidor (código ${response.statusCode})')
          .toString();
    } catch (_) {
      return 'Error de conexión o respuesta no válida (código ${response.statusCode}).';
    }
  }

  // Obtener todos los usuarios con el Token JWT guardado en SharedPreferences
  Future<List<UserModel>> obtenerUsuarios() async {
    final token = await _obtenerToken();
    if (token == null || token.isEmpty) {
      throw Exception('No hay sesión activa.');
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/usuarios');
    final response = await http.get(
      url,
      headers: {...ApiConfig.headers, 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List<dynamic> lista = decoded['usuarios'] ?? decoded;
      return lista.map((e) => UserModel.fromJson(e)).toList();
    } else {
      throw Exception(_mensajeError(response));
    }
  }

  Future<bool> crearUsuario({
    required String nombre,
    required String email,
    required String rol,
  }) async {
    final token = await _obtenerToken();
    if (token == null || token.isEmpty) {
      throw Exception('No hay sesión activa.');
    }

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/usuarios'),
      headers: {...ApiConfig.headers, 'Authorization': '******'},
      body: jsonEncode({'nombre': nombre, 'email': email, 'rol': rol}),
    );

    if (response.statusCode != 201) {
      throw Exception(_mensajeError(response));
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['existentePromovido'] == true;
  }

  // Cambiar el rol o aprobar a un usuario en estado 'pendiente'
  Future<void> cambiarRol(dynamic userId, String nuevoRol) async {
    final token = await _obtenerToken();
    if (token == null || token.isEmpty) {
      throw Exception('No hay sesión activa.');
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/usuarios/$userId/rol');
    final response = await http.put(
      url,
      headers: {...ApiConfig.headers, 'Authorization': 'Bearer $token'},
      body: jsonEncode({'rol': nuevoRol}),
    );

    if (response.statusCode != 200) {
      throw Exception(_mensajeError(response));
    }
  }

  // Eliminar un usuario del sistema de forma definitiva
  Future<void> eliminarUsuario(dynamic userId) async {
    final token = await _obtenerToken();
    if (token == null || token.isEmpty) {
      throw Exception('No hay sesión activa.');
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/usuarios/$userId');
    final response = await http.delete(
      url,
      headers: {...ApiConfig.headers, 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception(_mensajeError(response));
    }
  }
}
