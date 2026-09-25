 class ApiConfig {
  // Si usas emulador de Android usa '10.0.2.2', si usas dispositivo físico usa la IP de tu PC
  static const String baseUrl = 'http://10.0.2.2:3000/api'; 

  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}