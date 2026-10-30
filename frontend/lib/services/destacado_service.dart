import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_config.dart';
import '../models/destacado_model.dart';

class DestacadoService {
  static final ValueNotifier<int> cambios = ValueNotifier<int>(0);

  static void _notificarCambio() {
    cambios.value++;
  }

  static Future<String> _token() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null || token.isEmpty) {
      throw Exception('No hay sesión activa. Inicia sesión nuevamente.');
    }
    return token;
  }

static String _mensajeError(http.Response response) {
    // ⚠️ AGREGA ESTOS DOS PRINTS PARA VER QUÉ DICE EL BACKEND
    print('STATUS CODE DEL BACKEND: ${response.statusCode}');
    print('BODY DEL BACKEND: ${response.body}');

    try {
      final data = jsonDecode(response.body);
      return (data['message'] ??
              data['error'] ??
              'Error del servidor (código ${response.statusCode})')
          .toString();
    } catch (_) {
      return 'El servidor no respondió con JSON válido (código ${response.statusCode}). '
          'Verifica que el backend esté corriendo.';
    }
  }

  static Future<http.MultipartFile> _archivoImagen(File imagen) async {
    final bytes = await imagen.readAsBytes();
    final ext = imagen.path.split('.').last.toLowerCase();
    final subtipo = switch (ext) {
      'png' => 'png',
      'webp' => 'webp',
      'avif' => 'avif',
      _ => 'jpeg',
    };
    return http.MultipartFile.fromBytes(
      'imagen',
      bytes,
      filename:
          'destacado_${DateTime.now().millisecondsSinceEpoch}.${subtipo == 'jpeg' ? 'jpg' : subtipo}',
      contentType: MediaType('image', subtipo),
    );
  }

  /// Lista pública (la usa el home y el panel admin)
  static Future<List<DestacadoModel>> obtener() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/destacados'),
      headers: ApiConfig.headers,
    );
    if (response.statusCode != 200) {
      throw Exception(_mensajeError(response));
    }
    final List<dynamic> datos = jsonDecode(response.body);
    return datos
        .map((e) => DestacadoModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> crear({
    required String nombre,
    required String descripcion,
    required double precio,
    required File imagen,
  }) async {
    final token = await _token();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConfig.baseUrl}/destacados'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['nombre'] = nombre;
    request.fields['descripcion'] = descripcion;
    request.fields['precio'] = precio.toString();
    request.files.add(await _archivoImagen(imagen));

    final response = await http.Response.fromStream(await request.send());
    if (response.statusCode != 201) {
      throw Exception(_mensajeError(response));
    }
    _notificarCambio();
  }

  static Future<void> actualizar({
    required String id,
    required String nombre,
    required String descripcion,
    required double precio,
    File? imagen,
  }) async {
    final token = await _token();
    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('${ApiConfig.baseUrl}/destacados/$id'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['nombre'] = nombre;
    request.fields['descripcion'] = descripcion;
    request.fields['precio'] = precio.toString();
    if (imagen != null) {
      request.files.add(await _archivoImagen(imagen));
    }

    final response = await http.Response.fromStream(await request.send());
    if (response.statusCode != 200) {
      throw Exception(_mensajeError(response));
    }
    _notificarCambio();
  }

  static Future<void> eliminar(String id) async {
    final token = await _token();
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/destacados/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw Exception(_mensajeError(response));
    }
    _notificarCambio();
  }
}