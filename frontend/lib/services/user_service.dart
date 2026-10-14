import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../api_config.dart';

class UserService {
  // Petición POST para registrar un nuevo usuario
  Future<UserModel> registrarUsuario(UserModel usuario) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/registro');

    try {
      final response = await http.post(
        url,
        headers: ApiConfig.headers,
        body: jsonEncode(usuario.toJson()),
      );

      final contentType = response.headers['content-type'] ?? '';

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final usuarioResponse = responseData['usuario'] ?? responseData;
        return UserModel.fromJson(usuarioResponse);
      } else {
        if (contentType.contains('application/json')) {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          final String mensajeError =
              errorData['error'] ??
              errorData['message'] ??
              'Error desconocido en el servidor';
          throw Exception(mensajeError);
        } else {
          throw Exception(
            'Servidor no disponible o ruta no encontrada (Código ${response.statusCode})',
          );
        }
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Petición POST para iniciar sesión
  Future<Map<String, dynamic>> loginUsuario(
    String email,
    String password,
  ) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/login');

    try {
      final response = await http.post(
        url,
        headers: ApiConfig.headers,
        body: jsonEncode({'email': email, 'password': password}),
      );

      final contentType = response.headers['content-type'] ?? '';

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Devuelve el mapa completo con 'token' y 'usuario' tal como responde tu backend
        return responseData;
      } else {
        if (contentType.contains('application/json')) {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          final String mensajeError =
              errorData['error'] ??
              errorData['message'] ??
              'Credenciales incorrectas';
          throw Exception(mensajeError);
        } else {
          throw Exception(
            'Servidor no disponible o ruta no encontrada (Código ${response.statusCode})',
          );
        }
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<Map<String, dynamic>> verificarCuenta(
    String email,
    String codigo,
  ) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/verificar');

    try {
      final response = await http.post(
        url,
        headers: ApiConfig.headers,
        body: jsonEncode({'email': email.trim(), 'codigo': codigo.trim()}),
      );

      final contentType = response.headers['content-type'] ?? '';

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData;
      } else {
        if (contentType.contains('application/json')) {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          final String mensajeError =
              errorData['error'] ??
              errorData['message'] ??
              'Error al verificar la cuenta';
          throw Exception(mensajeError);
        } else {
          throw Exception(
            'Servidor no disponible o ruta no encontrada (Código ${response.statusCode})',
          );
        }
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Petición POST para autenticar con Google (Login / Registro unificado)
  Future<Map<String, dynamic>> autenticarConGoogleBackend(
    String idToken,
  ) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/google');

    try {
      final response = await http.post(
        url,
        headers: ApiConfig.headers,
        body: jsonEncode({'idToken': idToken}),
      );

      final contentType = response.headers['content-type'] ?? '';

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        // Retorna { message, token, usuario }
        return responseData;
      } else {
        if (contentType.contains('application/json')) {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          final String mensajeError =
              errorData['error'] ??
              errorData['message'] ??
              'Error al autenticar con Google';
          throw Exception(mensajeError);
        } else {
          throw Exception(
            'Servidor no disponible o ruta no encontrada (Código ${response.statusCode})',
          );
        }
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
