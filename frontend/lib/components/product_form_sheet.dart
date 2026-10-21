import 'dart:io';
import 'package:flutter/material.dart';
import '../models/producto_model.dart';
import '../services/admin_producto_service.dart';
import 'admin_page_selector.dart';
import 'package:elparchee/app_colors.dart';

/// Bottom sheet para crear (producto == null) o editar un producto.
/// Devuelve true si se guardó algo, para que la lista se recargue.
class ProductFormSheet extends StatefulWidget {
  final ProductoModel? producto;
  const ProductFormSheet({super.key, this.producto});

  static Future<bool> abrir(BuildContext context, {ProductoModel? producto}) async {
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
  late final _nombreCtrl =
      TextEditingController(text: widget.producto?.nombre ?? '');
  late final _descCtrl =
      TextEditingController(text: widget.producto?.descripcion ?? '');
  late final _precioCtrl = TextEditingController(
    text: widget.producto?.precio != null
        ? (widget.producto!.precio % 1 == 0
            ? widget.producto!.precio.toInt().toString()
            : widget.producto!.precio.toString())
        : '',
  );
  late String _categoria = widget.producto?.categoria ?? 'Otros';

  // Encuadre de la foto (arrastrar / zoom)
  final _capturaKey = GlobalKey();
  final _encuadreCtrl = TransformationController();

  File? _imagen;
  bool _guardando = false;
  bool get _esEdicion => widget.producto != null;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descCtrl.dispose();
    _precioCtrl.dispose();
    _encuadreCtrl.dispose();
    super.dispose();
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

  // Convierte el texto introducido en un double válido limpiando puntos de miles y comas
  double? _parsePrecio(String texto) {
    String limpio = texto.trim();
    if (limpio.isEmpty) return null;
    
    // Si contiene puntos y comas (ej. "25.000,00"), eliminamos los puntos de miles
    if (limpio.contains('.') && limpio.contains(',')) {
      limpio = limpio.replaceAll('.', '').replaceAll(',', '.');
    } else if (limpio.contains('.')) {
      // Si solo tiene puntos (ej. "25.000" como entero de miles), quitamos el punto
      // a menos que sea un decimal corto como "25.5"
      final partes = limpio.split('.');
      if (partes.last.length == 3) {
        limpio = limpio.replaceAll('.', '');
      }
    } else {
      limpio = limpio.replaceAll(',', '.');
    }
    
    return double.tryParse(limpio);
  }

  // Si el admin movió la foto, se sube el recorte tal como quedó en el recuadro
  Future<File?> _imagenParaSubir() async {
    final hayFoto = _imagen != null ||
        (widget.producto?.imagenUrl != null &&
            widget.producto!.imagenUrl.isNotEmpty);
    if (hayFoto && AdminImageSelector.encuadreModificado(_encuadreCtrl)) {
      return AdminImageSelector.capturarEncuadre(_capturaKey);
    }
    return _imagen; // null en edición = conserva la foto actual
  }

  Future<void> _guardar() async {
    // 1. Valida los campos de texto
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 2. Valida la imagen si es un producto nuevo
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
          imagen: imagen,
        );
      } else {
        await AdminProductService.crearProductos(
          nombre: nombre,
          descripcion: descripcion,
          precio: precio,
          categoria: categoria,
          imagen: imagen!,
        );
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) _error(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Widget _campo(TextEditingController ctrl, String etiqueta,
      {int maxLines = 1, bool esNumero = false}) {
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      // sube el formulario cuando aparece el teclado
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9),
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
                  value: _categoria,
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Hamburguesas',
                      child: Text('Hamburguesas'),
                    ),
                    DropdownMenuItem(
                      value: 'Perros calientes',
                      child: Text('Perros calientes'),
                    ),
                    DropdownMenuItem(
                      value: 'Salchipapas',
                      child: Text('Salchipapas'),
                    ),
                    DropdownMenuItem(
                      value: 'Otros',
                      child: Text('Otros'),
                    ),
                  ],
                  onChanged: _guardando
                      ? null
                      : (categoria) {
                          if (categoria != null) {
                            setState(() => _categoria = categoria);
                          }
                        },
                ),
                const SizedBox(height: 16),
                _campo(_nombreCtrl, 'Nombre del producto'),
                _campo(_descCtrl, 'Descripción', maxLines: 2),
                _campo(_precioCtrl, 'Precio', esNumero: true),
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