import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api_config.dart';

class ProfileService {
  Future<String> _token() async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString('jwt_token') ?? '';
    if (token.isEmpty) {
      throw Exception('La sesión expiró. Inicia sesión nuevamente.');
    }
    return token;
  }

  Future<Map<String, dynamic>> obtenerPerfil() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/usuarios/perfil'),
      headers: {
        ...ApiConfig.headers,
        'Authorization': 'Bearer ${await _token()}',
      },
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> actualizarPerfil({
    required String nombre,
    required String telefono,
    required String direccion,
    XFile? avatar,
  }) async {
    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('${ApiConfig.baseUrl}/usuarios/perfil'),
    );
    request.headers['Authorization'] = 'Bearer ${await _token()}';
    request.fields.addAll({
      'nombre': nombre,
      'telefono': telefono,
      'direccion': direccion,
    });
    if (avatar != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'avatar',
          await avatar.readAsBytes(),
          filename: avatar.name,
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final body = _decode(response);
    final profile = body['usuario'];
    if (profile is! Map<String, dynamic>) {
      throw Exception('El servidor no devolvió los datos del perfil actualizado.');
    }
    return profile;
  }

  Map<String, dynamic> _decode(http.Response response) {
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } on FormatException {
      throw Exception('El servidor devolvió una respuesta inválida.');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = body is Map<String, dynamic>
          ? body['error']?.toString()
          : null;
      throw Exception(message ?? 'Error del servidor (${response.statusCode}).');
    }
    if (body is! Map<String, dynamic>) {
      throw Exception('El servidor devolvió un perfil con formato inválido.');
    }
    return body;
  }
}
