import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../api_config.dart';

class RestaurantOrderService {
  Future<Map<String, String>> _headers() async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString('jwt_token') ?? '';
    if (token.isEmpty) {
      throw Exception('La sesión expiró. Inicia sesión nuevamente.');
    }
    return {
      ...ApiConfig.headers,
      'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final headers = await _headers();
    late final http.Response response;

    switch (method) {
      case 'GET':
        response = await http.get(uri, headers: headers);
        break;
      case 'POST':
        response = await http.post(
          uri,
          headers: headers,
          body: jsonEncode(body),
        );
        break;
      case 'PUT':
        response = await http.put(
          uri,
          headers: headers,
          body: jsonEncode(body),
        );
        break;
      default:
        throw ArgumentError.value(method, 'method', 'Método HTTP no soportado');
    }

    dynamic responseBody;
    if (response.body.isNotEmpty) {
      try {
        responseBody = jsonDecode(response.body);
      } on FormatException {
        throw Exception('El servidor devolvió una respuesta inválida.');
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = responseBody is Map<String, dynamic>
          ? responseBody['error']?.toString()
          : null;
      throw Exception(message ?? 'Error del servidor (${response.statusCode}).');
    }

    return responseBody;
  }

  Future<List<Map<String, dynamic>>> listarProductos() async {
    final response = await _request('GET', '/productos');
    if (response is! List) {
      throw Exception('La respuesta de productos no tiene el formato esperado.');
    }
    return response
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<List<Map<String, dynamic>>> listarPedidosMesero() async {
    return _listarPedidos('/pedidos/mis-pedidos');
  }

  Future<List<Map<String, dynamic>>> listarTodosLosPedidos() async {
    return _listarPedidos('/pedidos');
  }

  Future<List<Map<String, dynamic>>> listarPedidosCocina() async {
    return _listarPedidos('/pedidos');
  }

  Future<List<Map<String, dynamic>>> _listarPedidos(String path) async {
    final response = await _request('GET', path);
    if (response is! List) {
      throw Exception('La respuesta de pedidos no tiene el formato esperado.');
    }
    return response
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<Map<String, dynamic>> crearPedidoMesa({
    required String numeroMesa,
    required List<Map<String, dynamic>> productos,
  }) async {
    final response = await _request(
      'POST',
      '/pedidos',
      body: {
        'tipo_pedido': 'mesa',
        'numero_mesa': numeroMesa,
        'productos': productos,
      },
    );
    if (response is! Map<String, dynamic>) {
      throw Exception('El servidor no confirmó la creación del pedido.');
    }
    return response;
  }

  Future<Map<String, dynamic>> crearPedidoCliente({
    required String tipoPedido,
    required List<Map<String, dynamic>> productos,
    String? direccionEntrega,
  }) async {
    final response = await _request(
      'POST',
      '/pedidos',
      body: {
        'tipo_pedido': tipoPedido,
        'productos': productos,
        if (direccionEntrega != null) 'direccion_entrega': direccionEntrega,
      },
    );
    if (response is! Map<String, dynamic>) {
      throw Exception('El servidor no confirmó la creación del pedido.');
    }
    return response;
  }

  Future<List<Map<String, dynamic>>> listarPedidosCliente() async {
    return _listarPedidos('/pedidos/mis-pedidos');
  }

  Future<void> actualizarEstado(int pedidoId, String estado) async {
    await _request(
      'PUT',
      '/pedidos/$pedidoId/estado',
      body: {'estado': estado},
    );
  }
}
