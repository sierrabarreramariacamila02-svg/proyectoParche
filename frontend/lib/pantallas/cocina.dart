import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:elparchee/api_config.dart';
import 'package:elparchee/pantallas/cocina2.dart';
import 'package:shared_preferences/shared_preferences.dart';
 
class Cocina extends StatefulWidget {
  const Cocina({super.key});
 
  @override
  State<Cocina> createState() => _CocinaState();
}
 
class _CocinaState extends State<Cocina> {
  List<dynamic> _pedidos = [];
  bool _isLoading = true;
  String? _error;
 
  @override
  void initState() {
    super.initState();
    _cargarPedidosCocina();
  }
 
  // JWT guardado por el inicio de sesión (null si no existe)
  Future<String?> _token() async {
    final token = (await SharedPreferences.getInstance()).getString('jwt_token');
    return token == null || token.isEmpty ? null : token;
  }
 
  Map<String, String> _headers(String token) =>
      {...ApiConfig.headers, 'Authorization': 'Bearer $token'};
 
  // Extrae el mensaje de error de la respuesta o usa uno por defecto
  String _mensaje(http.Response r, String porDefecto) {
    final data = jsonDecode(r.body);
    return (data is Map<String, dynamic> ? data['error']?.toString() : null) ??
        porDefecto;
  }
 
  void _snack(BuildContext context, String texto) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
 
  // Función para conectar con el Backend y traer los pedidos
  Future<void> _cargarPedidosCocina() async {
    setState(() => _isLoading = true);
    _error = null;
    try {
      final token = await _token();
      if (token == null) {
        throw Exception('No se encontró la sesión. Inicia sesión nuevamente.');
      }
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/pedidos'),
        headers: _headers(token),
      );
      if (response.statusCode != 200) {
        throw Exception(
          _mensaje(
            response,
            'No se pudieron cargar los pedidos (${response.statusCode}).',
          ),
        );
      }
      final data = jsonDecode(response.body);
      if (data is! List) {
        throw const FormatException(
          'La respuesta de cocina no tiene el formato esperado.',
        );
      }
      if (!mounted) return;
      setState(() {
        _pedidos = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }
 
  // Navega a Cocina2 y recarga la lista si el pedido fue completado
  Future<void> _abrirCocina2(
    BuildContext context,
    Map<String, dynamic> pedido,
    String tiempo,
  ) async {
    final completado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => Cocina2(pedido: pedido, tiempoPrep: tiempo),
      ),
    );
    if (completado == true) _cargarPedidosCocina();
  }
 
  Future<void> _iniciarPreparacion(
    BuildContext context,
    Map<String, dynamic> pedido,
    String numero,
    String tiempo,
  ) async {
    final token = await _token();
    if (token == null) {
      if (context.mounted) _snack(context, 'Inicia sesión nuevamente.');
      return;
    }
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/pedidos/$numero/estado'),
        headers: _headers(token),
        body: jsonEncode({'estado': 'en_preparacion'}),
      );
      if (response.statusCode != 200) {
        throw Exception(_mensaje(response, 'No se pudo iniciar la preparación.'));
      }
      if (context.mounted) await _abrirCocina2(context, pedido, tiempo);
    } catch (e) {
      if (context.mounted) {
        _snack(context, e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }
 
  @override
  Widget build(BuildContext context) {
    // Contadores dinámicos basados en el estado que devuelva tu backend
    String estadoDe(dynamic registro) {
      if (registro is! Map) return '';
      final pedido = registro['pedido'];
      return (registro['estado'] ??
              (pedido is Map ? pedido['estado'] : null) ??
              '')
          .toString()
          .toLowerCase();
    }
 
    int contar(List<String> estados) =>
        _pedidos.where((p) => estados.contains(estadoDe(p))).length;
 
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 243, 230),
      body: Column(
        children: [
          // Encabezado rojo
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            color: const Color.fromARGB(255, 139, 18, 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Pedidos pendientes!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: _cargarPedidosCocina,
                ),
              ],
            ),
          ),
 
          // Chips de estado dinámicos
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _chip("nuevos (${contar(['nuevo', 'pendiente'])})", Colors.orange),
                const SizedBox(width: 8),
                _chip(
                  "en preparación (${contar(['en_preparacion'])})",
                  Colors.grey.shade300,
                ),
                const SizedBox(width: 8),
                _chip("listos (${contar(['listo'])})", Colors.grey.shade300),
              ],
            ),
          ),
 
          // Lista de pedidos conectada a la BD o indicador de carga
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.orange),
                  )
                : _error != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _cargarPedidosCocina,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  )
                : _pedidos.isEmpty
                ? const Center(
                    child: Text(
                      "No hay pedidos pendientes por ahora",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    itemCount: _pedidos.length,
                    itemBuilder: (context, index) {
                      final registro = Map<String, dynamic>.from(
                        _pedidos[index] as Map,
                      );
                      final pedido = registro['pedido'] is Map
                          ? Map<String, dynamic>.from(registro['pedido'] as Map)
                          : registro;
                      final idPedido =
                          (pedido['id'] ??
                                  registro['pedido_id'] ??
                                  registro['id'] ??
                                  'S/N')
                              .toString();
                      final tiempoPrep =
                          (registro['tiempo_prep'] ??
                                  pedido['tiempo_prep'] ??
                                  '09:12 min')
                              .toString();
                      final items = pedido['items'] is List
                          ? pedido['items'] as List<dynamic>
                          : pedido['detalle_pedido'] is List
                          ? pedido['detalle_pedido'] as List<dynamic>
                          : <dynamic>[];
 
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: _pedidoCard(
                          context,
                          pedido,
                          idPedido,
                          tiempoPrep,
                          items,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
 
  Widget _chip(String texto, Color color) => Chip(
    label: Text(texto, style: const TextStyle(fontSize: 12)),
    backgroundColor: color,
  );
 
  Widget _pedidoCard(
    BuildContext context,
    Map<String, dynamic> pedido,
    String numero,
    String tiempo,
    List<dynamic> items,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "#$numero",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Text(
                    "Prep Time: $tiempo",
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
 
          // Renderiza los productos del pedido de forma dinámica
          if (items.isEmpty)
            const Text(
              "Sin productos especificados",
              style: TextStyle(color: Colors.grey),
            )
          else
            ...items.map((item) {
              final producto = item is Map && item['producto'] is Map
                  ? item['producto'] as Map
                  : item;
              final nombre = producto is Map
                  ? producto['nombre']?.toString() ?? 'Producto'
                  : 'Producto';
              final progreso = item is Map
                  ? double.tryParse(item['progreso']?.toString() ?? '') ?? 0.0
                  : 0.0;
              return _item(nombre, progreso);
            }),
 
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _iniciarPreparacion(context, pedido, numero, tiempo),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text("Iniciar Preparación"),
            ),
          ),
 
          // NUEVO: botón que lleva directamente a Cocina2
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _abrirCocina2(context, pedido, tiempo),
              icon: const Icon(Icons.receipt_long),
              label: const Text("Ver detalle del pedido"),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }
 
  Widget _item(String nombre, double progreso) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          const Icon(Icons.fastfood, size: 18, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(child: Text(nombre, style: const TextStyle(fontSize: 13))),
          SizedBox(
            width: 80,
            child: LinearProgressIndicator(
              value: progreso,
              color: Colors.red,
              backgroundColor: Colors.grey.shade300,
            ),
          ),
        ],
      ),
    );
  }
}
 