import 'dart:convert';

import 'package:elparchee/api_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Cocina2 extends StatefulWidget {
  const Cocina2({super.key, required this.pedido, required this.tiempoPrep});

  final Map<String, dynamic> pedido;
  final String tiempoPrep;

  @override
  State<Cocina2> createState() => _Cocina2State();
}

class _Cocina2State extends State<Cocina2> {
  late Map<String, dynamic> _pedido = widget.pedido;
  final Map<int, bool> _itemsCompletados = {};
  bool _isLoading = true;
  bool _saving = false;
  String? _error;

  String get _pedidoId => (_pedido['id'] ?? '').toString();

  @override
  void initState() {
    super.initState();
    _cargarPedido();
  }

  Future<Map<String, String>?> _headersAutenticados() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null || token.isEmpty) return null;
    return {...ApiConfig.headers, 'Authorization': 'Bearer $token'};
  }

  Future<void> _cargarPedido() async {
    try {
      final headers = await _headersAutenticados();
      if (headers == null) {
        throw Exception('Inicia sesión nuevamente para ver el pedido.');
      }
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/pedidos/$_pedidoId'),
        headers: headers,
      );
      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);
        throw Exception(
          data is Map<String, dynamic>
              ? data['error'] ?? 'No se pudo cargar el pedido.'
              : 'No se pudo cargar el pedido.',
        );
      }
      final data = jsonDecode(response.body);
      if (data is! Map<String, dynamic>) {
        throw const FormatException(
          'El pedido recibido no tiene el formato esperado.',
        );
      }
      if (!mounted) return;
      setState(() {
        _pedido = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _completarPedido() async {
    setState(() => _saving = true);
    try {
      final headers = await _headersAutenticados();
      if (headers == null) {
        throw Exception('Inicia sesión nuevamente para actualizar el pedido.');
      }

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/pedidos/$_pedidoId/estado'),
        headers: headers,
        body: jsonEncode({'estado': 'listo'}),
      );
      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);
        throw Exception(
          data is Map<String, dynamic>
              ? data['error'] ?? 'No se pudo completar el pedido.'
              : 'No se pudo completar el pedido.',
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detalles = _pedido['detalle_pedido'] is List
        ? _pedido['detalle_pedido'] as List<dynamic>
        : <dynamic>[];
    final numeroMesa = _pedido['numero_mesa'];

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 243, 230),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(15, 50, 15, 15),
            color: const Color.fromARGB(255, 139, 18, 18),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: Text(
                    'Detalle del pedido #$_pedidoId',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const CircleAvatar(
                  radius: 18,
                  backgroundImage: AssetImage(
                    'assets/images/Logo_el_parche.png',
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            color: const Color.fromARGB(255, 232, 188, 123),
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#$_pedidoId',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Prep time ${widget.tiempoPrep}',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
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
                          onPressed: () {
                            setState(() {
                              _isLoading = true;
                              _error = null;
                            });
                            _cargarPedido();
                          },
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(15),
                    children: [
                      const Text(
                        'Productos del pedido',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (detalles.isEmpty)
                        const Text(
                          'El pedido no tiene productos especificados.',
                        )
                      else
                        ...detalles.asMap().entries.map((entry) {
                          final detalle = entry.value is Map
                              ? Map<String, dynamic>.from(entry.value as Map)
                              : <String, dynamic>{};
                          final producto = detalle['producto'] is Map
                              ? Map<String, dynamic>.from(
                                  detalle['producto'] as Map,
                                )
                              : detalle;
                          final cantidad = detalle['cantidad'];
                          return _itemCheck(
                            (producto['nombre'] ?? 'Producto').toString(),
                            cantidad == null ? '' : 'Cantidad: $cantidad',
                            _itemsCompletados[entry.key] ?? false,
                            (valor) => setState(
                              () =>
                                  _itemsCompletados[entry.key] = valor ?? false,
                            ),
                          );
                        }),
                      const SizedBox(height: 15),
                      const Text(
                        'Nota de la comanda',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color.fromARGB(255, 228, 171, 86),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          numeroMesa == null
                              ? 'Sin nota adicional'
                              : 'Mesa $numeroMesa',
                        ),
                      ),
                    ],
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading || _error != null || _saving
                    ? null
                    : _completarPedido,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 233, 163, 58),
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  _saving ? 'Guardando...' : 'Marcar pedido completado',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemCheck(
    String nombre,
    String detalle,
    bool valor,
    ValueChanged<bool?> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Checkbox(
            value: valor,
            onChanged: onChanged,
            activeColor: Colors.orange,
          ),
          const Icon(Icons.fastfood, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (detalle.isNotEmpty)
                  Text(
                    detalle,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
