import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';

class ApiService {
  
  /// Método para iniciar sesión enviando correo y contraseña al backend en Java
  Future<bool> iniciarSesion(String email, String password) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/login');

      final response = await http.post(
        url,
        headers: ApiConfig.headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      // Si el backend responde con un 200 OK, el login fue exitoso
      if (response.statusCode == 200) {
        // Opcional: Si tu backend te devuelve un token, puedes capturarlo así:
        // final data = jsonDecode(response.body);
        // String token = data['token']; 
        
        return true;
      } else {
        // Credenciales incorrectas o error controlado por el backend
        return false;
      }
    } catch (e) {
      // Errores de red (servidor apagado, sin internet, IP incorrecta)
      print('Error de conexión en el login: $e');
      return false;
    }
  }

  // Aquí mismo puedes ir agregando más funciones a futuro (ej. registrarse, traer listas, etc.)
}