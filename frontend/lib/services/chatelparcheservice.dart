import 'dart:convert';
import 'package:frontend/api_config.dart';
import 'package:http/http.dart' as http;

class ChatParcheService {
  // Concatena directamente con tu baseUrl existente ('.../api/chat-mimos')
  static String get _chatUrl => '${ApiConfig.baseUrl}/chat-elparche';

  static Future<String> enviarMensaje(String mensaje, {String? sesionId}) async {
    try {
      final response = await http.post(
        Uri.parse(_chatUrl),
        headers: ApiConfig.headers,
        body: jsonEncode({
          'mensaje': mensaje,
          'sesionId': sesionId ?? 'mimos_cliente_${DateTime.now().millisecondsSinceEpoch}',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['respuesta'] ?? 'No se recibió respuesta.';
      } else {
        return 'En este momento no pudimos procesar tu solicitud.';
      }
    } catch (e) {
      return 'Error de conexión con la heladería. Revisa tu servidor.';
    }
  }
}