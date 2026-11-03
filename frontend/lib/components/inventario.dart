import 'dart:convert';

import 'package:elparchee/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../api_config.dart';

class InventarioScreen extends StatefulWidget {
  const InventarioScreen({super.key});

  @override
  State<InventarioScreen> createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> {
  late Future<List<Map<String, dynamic>>> _inventario;

  @override
  void initState() {
    super.initState();
    _inventario = _cargarInventario();
  }

  Future<String> _token() async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString('jwt_token') ?? '';
    if (token.isEmpty) {
      throw Exception('La sesión expiró. Inicia sesión nuevamente.');
    }
    return token;
  }

  Future<dynamic> _request(
    String method, {
    String? id,
    Map<String, dynamic>? body,
  }) async {
    final token = await _token();
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/inventario${id == null ? '' : '/$id'}',
    );
    final headers = {...ApiConfig.headers, 'Authorization': 'Bearer $token'};
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
      case 'DELETE':
        response = await http.delete(uri, headers: headers);
        break;
      default:
        throw ArgumentError.value(method, 'method', 'Método no soportado.');
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
      throw Exception(
        message ?? 'Error del servidor (${response.statusCode}).',
      );
    }
    return responseBody;
  }

  Future<List<Map<String, dynamic>>> _cargarInventario() async {
    final response = await _request('GET');
    if (response is! List) {
      throw Exception('La respuesta del inventario tiene un formato inválido.');
    }
    return response
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  void _recargar() {
    setState(() {
      _inventario = _cargarInventario();
    });
  }

  Future<void> _editarIngrediente([Map<String, dynamic>? item]) async {
    final values = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _InventarioIngredienteDialog(item: item),
    );

    if (values == null || !mounted) return;

    try {
      await _request(
        item == null ? 'POST' : 'PUT',
        id: item?['id']?.toString(),
        body: values,
      );
      if (!mounted) return;
      _recargar();
      _mensaje(
        item == null ? 'Ingrediente agregado.' : 'Ingrediente actualizado.',
      );
    } catch (error) {
      if (mounted) _mensaje(_errorText(error), error: true);
    }
  }

  Future<void> _eliminarIngrediente(Map<String, dynamic> item) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar ingrediente'),
        content: Text('¿Quieres eliminar "${item['nombre']}" del inventario?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.barraHome),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;

    try {
      await _request('DELETE', id: item['id'].toString());
      if (!mounted) return;
      _recargar();
      _mensaje('Ingrediente eliminado.');
    } catch (error) {
      if (mounted) _mensaje(_errorText(error), error: true);
    }
  }

  String _errorText(Object error) =>
      error.toString().replaceFirst('Exception: ', '');

  void _mensaje(String text, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: error ? AppColors.barraHome : Colors.green.shade800,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Inventario'),
        backgroundColor: AppColors.barraHome,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Actualizar inventario',
            onPressed: _recargar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _editarIngrediente(),
        backgroundColor: AppColors.buttonOrange,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Ingrediente'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _inventario,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.barraHome),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.barraHome,
                      size: 44,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _errorText(snapshot.error!),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _recargar,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Aún no hay ingredientes. Usa “Ingrediente” para agregar el primero.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.barraHome,
            onRefresh: () async {
              final nuevaCarga = _cargarInventario();
              setState(() {
                _inventario = nuevaCarga;
              });
              try {
                await nuevaCarga;
              } catch (error) {
                if (mounted) _mensaje(_errorText(error), error: true);
              }
            },
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final cantidad = _numero(item['cantidad']);
                final minimo = _numero(item['stock_minimo']);
                final stockBajo = cantidad <= minimo;
                final unidad = item['unidad_medida']?.toString() ?? '';

                return Card(
                  color: AppColors.inputBackground,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.barraInferior,
                      child: Icon(
                        stockBajo
                            ? Icons.warning_amber_rounded
                            : Icons.inventory_2_outlined,
                        color: stockBajo
                            ? AppColors.barraHome
                            : Colors.green.shade800,
                      ),
                    ),
                    title: Text(
                      item['nombre']?.toString() ?? 'Ingrediente',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Stock: ${_formatear(cantidad)} $unidad'
                            ' · Mínimo: ${_formatear(minimo)} $unidad',
                          ),
                          const SizedBox(height: 6),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: stockBajo
                                  ? AppColors.barraHome.withValues(alpha: 0.1)
                                  : Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              child: Text(
                                stockBajo ? 'Stock bajo' : 'Disponible',
                                style: TextStyle(
                                  color: stockBajo
                                      ? AppColors.barraHome
                                      : Colors.green.shade800,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: PopupMenuButton<String>(
                      tooltip: 'Acciones del ingrediente',
                      onSelected: (action) {
                        if (action == 'edit') {
                          _editarIngrediente(item);
                        } else {
                          _eliminarIngrediente(item);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'edit', child: Text('Editar')),
                        PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                      ],
                      icon: const Icon(Icons.more_vert),
                    ),
                    onTap: () => _editarIngrediente(item),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  double _numero(dynamic value) =>
      value is num ? value.toDouble() : double.tryParse(value.toString()) ?? 0;

  String _formatear(double value) => value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toString();
}

class _InventarioIngredienteDialog extends StatefulWidget {
  final Map<String, dynamic>? item;

  const _InventarioIngredienteDialog({this.item});

  @override
  State<_InventarioIngredienteDialog> createState() =>
      _InventarioIngredienteDialogState();
}

class _InventarioIngredienteDialogState
    extends State<_InventarioIngredienteDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _cantidad;
  late final TextEditingController _unidad;
  late final TextEditingController _minimo;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _nombre = TextEditingController(text: item?['nombre']?.toString() ?? '');
    _cantidad = TextEditingController(
      text: item?['cantidad']?.toString() ?? '',
    );
    _unidad = TextEditingController(
      text: item?['unidad_medida']?.toString() ?? '',
    );
    _minimo = TextEditingController(
      text: item?['stock_minimo']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nombre.dispose();
    _cantidad.dispose();
    _unidad.dispose();
    _minimo.dispose();
    super.dispose();
  }

  Widget _campo(
    TextEditingController controller,
    String label, {
    bool numeric = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: numeric
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: AppColors.inputBackground,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) {
          final text = value?.trim() ?? '';
          if (text.isEmpty) return 'Este campo es obligatorio.';
          if (numeric) {
            final number = double.tryParse(text.replaceAll(',', '.'));
            if (number == null || number < 0) {
              return 'Ingresa un número válido, igual o mayor que cero.';
            }
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.item == null ? 'Agregar ingrediente' : 'Editar ingrediente',
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _campo(_nombre, 'Nombre'),
              _campo(_cantidad, 'Cantidad disponible', numeric: true),
              _campo(_unidad, 'Unidad de medida (kg, g, unidades...)'),
              _campo(_minimo, 'Stock mínimo de alerta', numeric: true),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.barraHome),
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(context, {
              'nombre': _nombre.text.trim(),
              'cantidad': double.parse(
                _cantidad.text.trim().replaceAll(',', '.'),
              ),
              'unidad_medida': _unidad.text.trim(),
              'stock_minimo': double.parse(
                _minimo.text.trim().replaceAll(',', '.'),
              ),
            });
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
