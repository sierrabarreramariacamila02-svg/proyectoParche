import 'dart:io';
import 'package:flutter/material.dart';
import '../models/producto_model.dart';
import '../services/admin_producto_service.dart';
import 'admin_page_selector.dart';
import 'package:elparchee/app_colors.dart';

class ProductFormSheet extends StatefulWidget {
  final ProductoModel? producto;
  const ProductFormSheet({super.key, this.producto});

  static Future<bool> abrir(
    BuildContext context, {
    ProductoModel? producto,
  }) async {
    final guardado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductFormSheet(producto: producto),
    );
    return guardado == true;
  }

  @override
  State<ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends State<ProductFormSheet> {
  static const Color _colorPrincipal = AppColors.barraHome;

  final _formKey = GlobalKey<FormState>();
  late final _nombreCtrl = TextEditingController(
    text: widget.producto?.nombre ?? '',
  );
  late final _descCtrl = TextEditingController(
    text: widget.producto?.descripcion ?? '',
  );
  late final _precioCtrl = TextEditingController(
    text: widget.producto?.precio != null
        ? (widget.producto!.precio % 1 == 0
              ? widget.producto!.precio.toInt().toString()
              : widget.producto!.precio.toString())
        : '',
  );

  final _nuevaPersCtrl = TextEditingController();
  final _nuevoAcompNombreCtrl = TextEditingController();
  final _nuevoAcompPrecioCtrl = TextEditingController();
  final _nuevaBebidaNombreCtrl = TextEditingController();
  final _nuevaBebidaPrecioCtrl = TextEditingController();

  static const List<String> _categoriasOpciones = [
    'Hamburguesas',
    'Perros calientes',
    'Salchipapas',
    'Otros',
  ];

  late String _categoria;
  late bool _destacado = widget.producto?.destacado ?? false;
  late List<String> _personalizaciones;
  late List<OpcionExtraProducto> _acompanamientos;
  late List<OpcionExtraProducto> _bebidas;

  final _capturaKey = GlobalKey();
  final _encuadreCtrl = TransformationController();

  File? _imagen;
  bool _guardando = false;
  bool get _esEdicion => widget.producto != null;

  @override
  void initState() {
    super.initState();
    _categoria = _obtenerCategoriaValida(widget.producto?.categoria);
    _personalizaciones = List<String>.from(
      widget.producto?.personalizaciones ?? const [],
    );
    _acompanamientos = List<OpcionExtraProducto>.from(
      widget.producto?.acompanamientos ?? const [],
    );
    _bebidas = List<OpcionExtraProducto>.from(
      widget.producto?.bebidas ?? const [],
    );
  }

  String _obtenerCategoriaValida(String? catOriginal) {
    if (catOriginal == null || catOriginal.trim().isEmpty) return 'Otros';
    final strLimpio = catOriginal.trim().toLowerCase();

    if (strLimpio.contains('hamburguesa')) return 'Hamburguesas';
    if (strLimpio.contains('perro')) return 'Perros calientes';
    if (strLimpio.contains('salchipapa')) return 'Salchipapas';
    return 'Otros';
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descCtrl.dispose();
    _precioCtrl.dispose();
    _nuevaPersCtrl.dispose();
    _nuevoAcompNombreCtrl.dispose();
    _nuevoAcompPrecioCtrl.dispose();
    _nuevaBebidaNombreCtrl.dispose();
    _nuevaBebidaPrecioCtrl.dispose();
    _encuadreCtrl.dispose();
    super.dispose();
  }

  // --- CRUD PERSONALIZACIONES ---
  void _agregarPersonalizacion() {
    final texto = _nuevaPersCtrl.text.trim();
    if (texto.isEmpty) return;
    if (!_personalizaciones.contains(texto)) {
      setState(() {
        _personalizaciones.add(texto);
        _nuevaPersCtrl.clear();
      });
    }
  }

  Future<void> _editarPersonalizacion(int index) async {
    final ctrl = TextEditingController(text: _personalizaciones[index]);
    final nuevo = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar personalización'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Ej: Sin cebolla, Sin azúcar...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _colorPrincipal,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (nuevo != null && nuevo.isNotEmpty) {
      setState(() => _personalizaciones[index] = nuevo);
    }
  }

  void _eliminarPersonalizacion(int index) {
    setState(() => _personalizaciones.removeAt(index));
  }

  // --- CRUD ACOMPAÑAMIENTOS Y BEBIDAS ---
  void _agregarExtra({
    required TextEditingController nombreCtrl,
    required TextEditingController precioCtrl,
    required List<OpcionExtraProducto> destino,
  }) {
    final nombre = nombreCtrl.text.trim();
    if (nombre.isEmpty) return;
    final precio = _parsePrecio(precioCtrl.text) ?? 0.0;
    setState(() {
      destino.add(OpcionExtraProducto(nombre: nombre, precio: precio));
      nombreCtrl.clear();
      precioCtrl.clear();
    });
  }

  Future<void> _editarExtra({
    required String tituloDialogo,
    required List<OpcionExtraProducto> lista,
    required int index,
  }) async {
    final actual = lista[index];
    final nombreCtrl = TextEditingController(text: actual.nombre);
    final precioCtrl = TextEditingController(
      text: actual.precio > 0 ? actual.precio.toStringAsFixed(0) : '',
    );

    final editado = await showDialog<OpcionExtraProducto>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tituloDialogo),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreCtrl,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: precioCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Precio adicional (COP)',
                prefixText: '\$ ',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _colorPrincipal,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final n = nombreCtrl.text.trim();
              if (n.isEmpty) return;
              final p = _parsePrecio(precioCtrl.text) ?? 0.0;
              Navigator.pop(ctx, OpcionExtraProducto(nombre: n, precio: p));
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (editado != null) {
      setState(() => lista[index] = editado);
    }
  }

  void _error(String msg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error al guardar'),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  double? _parsePrecio(String texto) {
    String limpio = texto.trim();
    if (limpio.isEmpty) return null;

    if (limpio.contains('.') && limpio.contains(',')) {
      limpio = limpio.replaceAll('.', '').replaceAll(',', '.');
    } else if (limpio.contains('.')) {
      final partes = limpio.split('.');
      if (partes.last.length == 3) {
        limpio = limpio.replaceAll('.', '');
      }
    } else {
      limpio = limpio.replaceAll(',', '.');
    }

    return double.tryParse(limpio);
  }

  Future<File?> _imagenParaSubir() async {
    final hayFoto =
        _imagen != null ||
        (widget.producto?.imagenUrl != null &&
            widget.producto!.imagenUrl.isNotEmpty);
    if (hayFoto && AdminImageSelector.encuadreModificado(_encuadreCtrl)) {
      return AdminImageSelector.capturarEncuadre(_capturaKey);
    }
    return _imagen;
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_esEdicion && _imagen == null) {
      _error('Selecciona una imagen');
      return;
    }

    setState(() => _guardando = true);

    try {
      final nombre = _nombreCtrl.text.trim();
      final descripcion = _descCtrl.text.trim();

      final precioParsed = _parsePrecio(_precioCtrl.text);
      if (precioParsed == null) {
        _error('Ingresa un precio válido');
        setState(() => _guardando = false);
        return;
      }
      final double precio = precioParsed;
      final categoria = _categoria;

      final imagen = await _imagenParaSubir();

      if (_esEdicion) {
        await AdminProductService.actualizarProductos(
          id: widget.producto!.id,
          nombre: nombre,
          descripcion: descripcion,
          precio: precio,
          categoria: categoria,
          destacado: _destacado,
          personalizaciones: _personalizaciones,
          acompanamientos: _acompanamientos,
          bebidas: _bebidas,
          imagen: imagen,
        );
      } else {
        await AdminProductService.crearProductos(
          nombre: nombre,
          descripcion: descripcion,
          precio: precio,
          categoria: categoria,
          destacado: _destacado,
          personalizaciones: _personalizaciones,
          acompanamientos: _acompanamientos,
          bebidas: _bebidas,
          imagen: imagen!,
        );
      }

      final esDescuento = _esEdicion && precio < widget.producto!.precio;
      final debeNotificar = !_esEdicion || esDescuento;
      String? errorNotificacion;

      if (debeNotificar) {
        final tituloNotif = esDescuento
            ? 'Descuento en $nombre'
            : 'Nuevo producto en El Parche';
        final cuerpoNotif = esDescuento
            ? 'El precio de "$nombre" bajó de '
                  '\$${widget.producto!.precio.toStringAsFixed(0)} a '
                  '\$${precio.toStringAsFixed(0)}.'
            : 'Prueba nuestro nuevo plato "$nombre". $descripcion';

        try {
          await AdminProductService.guardarNotificacionProducto(
            titulo: tituloNotif,
            cuerpo: cuerpoNotif,
          );
        } catch (error) {
          debugPrint('Error registrando notificación: $error');
          errorNotificacion = error.toString();
        }
      }

      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        Navigator.pop(context, true);
        if (errorNotificacion != null) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                'El producto se guardó, pero no se pudo guardar la '
                'notificación: $errorNotificacion',
              ),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) _error(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Widget _campo(
    TextEditingController ctrl,
    String etiqueta, {
    int maxLines = 1,
    bool esNumero = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        enabled: !_guardando,
        keyboardType: esNumero
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        decoration: InputDecoration(
          labelText: etiqueta,
          prefixText: esNumero ? '\$ ' : null,
          border: const OutlineInputBorder(),
        ),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'Campo obligatorio';
          if (esNumero && _parsePrecio(v) == null) {
            return 'Ingresa un número válido';
          }
          return null;
        },
      ),
    );
  }

  Widget _seccionExtras({
    required String titulo,
    required String hintNombre,
    required String tituloEditar,
    required TextEditingController nombreCtrl,
    required TextEditingController precioCtrl,
    required List<OpcionExtraProducto> lista,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: _colorPrincipal,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: nombreCtrl,
                enabled: !_guardando,
                decoration: InputDecoration(
                  hintText: hintNombre,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              flex: 2,
              child: TextField(
                controller: precioCtrl,
                enabled: !_guardando,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Precio',
                  prefixText: '\$',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 6),
            IconButton.filled(
              style: IconButton.styleFrom(backgroundColor: _colorPrincipal),
              onPressed: _guardando
                  ? null
                  : () => _agregarExtra(
                      nombreCtrl: nombreCtrl,
                      precioCtrl: precioCtrl,
                      destino: lista,
                    ),
              icon: const Icon(Icons.add, color: Colors.white),
              tooltip: 'Agregar',
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (lista.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 6),
            child: Text(
              'Sin opciones configuradas.',
              style: TextStyle(color: Colors.black54, fontSize: 13),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: lista.length,
            itemBuilder: (_, index) {
              final item = lista[index];
              return Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 6),
                child: ListTile(
                  dense: true,
                  title: Text(item.nombre),
                  subtitle: Text(
                    item.precio > 0
                        ? '+\$${item.precio.toStringAsFixed(0)} COP'
                        : 'Sin costo adicional',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        tooltip: 'Modificar',
                        onPressed: _guardando
                            ? null
                            : () => _editarExtra(
                                tituloDialogo: tituloEditar,
                                lista: lista,
                                index: index,
                              ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 18,
                        ),
                        tooltip: 'Eliminar',
                        onPressed: _guardando
                            ? null
                            : () => setState(() => lista.removeAt(index)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFFF6F4F0),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  _esEdicion ? 'Editar producto' : 'Nuevo producto',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _colorPrincipal,
                  ),
                ),
                const SizedBox(height: 16),
                AdminImageSelector(
                  imagen: _imagen,
                  imagenUrl: widget.producto?.imagenUrl,
                  habilitado: !_guardando,
                  capturaKey: _capturaKey,
                  encuadreController: _encuadreCtrl,
                  onImagenSeleccionada: (file) =>
                      setState(() => _imagen = file),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _categoria,
                  decoration: const InputDecoration(
                    labelText: 'Categoría del menú',
                    border: OutlineInputBorder(),
                  ),
                  items: _categoriasOpciones.map((cat) {
                    return DropdownMenuItem<String>(
                      value: cat,
                      child: Text(cat),
                    );
                  }).toList(),
                  onChanged: _guardando
                      ? null
                      : (nuevaCat) {
                          if (nuevaCat != null) {
                            setState(() => _categoria = nuevaCat);
                          }
                        },
                ),
                const SizedBox(height: 16),
                _campo(_nombreCtrl, 'Nombre del producto'),
                _campo(_descCtrl, 'Descripción', maxLines: 2),
                _campo(_precioCtrl, 'Precio', esNumero: true),

                // --- PERSONALIZACIONES ---
                const SizedBox(height: 4),
                const Text(
                  'Personalizaciones',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: _colorPrincipal,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nuevaPersCtrl,
                        enabled: !_guardando,
                        decoration: const InputDecoration(
                          hintText: 'Ej: Sin cebolla, Sin azúcar...',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onSubmitted: (_) => _agregarPersonalizacion(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      style: IconButton.styleFrom(
                        backgroundColor: _colorPrincipal,
                      ),
                      onPressed: _guardando ? null : _agregarPersonalizacion,
                      icon: const Icon(Icons.add, color: Colors.white),
                      tooltip: 'Agregar personalización',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_personalizaciones.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      'No hay personalizaciones agregadas.',
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _personalizaciones.length,
                    itemBuilder: (_, index) {
                      return Card(
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 6),
                        child: ListTile(
                          dense: true,
                          title: Text(_personalizaciones[index]),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 18),
                                tooltip: 'Modificar',
                                onPressed: _guardando
                                    ? null
                                    : () => _editarPersonalizacion(index),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                  size: 18,
                                ),
                                tooltip: 'Eliminar',
                                onPressed: _guardando
                                    ? null
                                    : () => _eliminarPersonalizacion(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                // --- ACOMPAÑAMIENTOS ---
                _seccionExtras(
                  titulo: 'Acompañamientos',
                  hintNombre: 'Ej: Papas en casco',
                  tituloEditar: 'Editar acompañamiento',
                  nombreCtrl: _nuevoAcompNombreCtrl,
                  precioCtrl: _nuevoAcompPrecioCtrl,
                  lista: _acompanamientos,
                ),

                // --- BEBIDAS ---
                _seccionExtras(
                  titulo: 'Bebidas (según disponibilidad)',
                  hintNombre: 'Ej: Pepsi zero',
                  tituloEditar: 'Editar bebida',
                  nombreCtrl: _nuevaBebidaNombreCtrl,
                  precioCtrl: _nuevaBebidaPrecioCtrl,
                  lista: _bebidas,
                ),

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Plato destacado'),
                  subtitle: const Text(
                    'Se mostrará en "Productos destacados" del inicio',
                  ),
                  value: _destacado,
                  onChanged: _guardando
                      ? null
                      : (v) => setState(() => _destacado = v),
                ),
                const SizedBox(height: 6),
                ElevatedButton(
                  onPressed: _guardando ? null : _guardar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _colorPrincipal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _guardando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _esEdicion ? 'GUARDAR CAMBIOS' : 'CREAR PRODUCTO',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
