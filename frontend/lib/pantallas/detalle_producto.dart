
import 'package:flutter/material.dart';
import 'package:elparchee/models/producto_model.dart';
import 'package:elparchee/pantallas/carrito.dart';

class ProductDetailScreen extends StatefulWidget {
  final String title;
  final String imageUrl;
  final String price;
  final String name;
  final String description;
  final double rawPrice;
  final List<String> personalizaciones;
  final List<OpcionExtraProducto> bebidas;
  final List<String> initialPersonalizaciones;
  final String? initialBebida;
  final bool initialSinCebolla;
  final bool initialSinLechuga;
  final int initialCantidad;
  final Function(Map<String, dynamic> nuevoItem)? onAgregarAlCarrito;

  const ProductDetailScreen({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.name,
    required this.description,
    this.rawPrice = 30000.0,
    this.personalizaciones = const [],
    this.bebidas = const [],
    this.initialPersonalizaciones = const [],
    this.initialBebida,
    this.initialSinCebolla = false,
    this.initialSinLechuga = false,
    this.initialCantidad = 1,
    this.onAgregarAlCarrito,
  });

  @override
  State<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int cantidad = 1;
  int paginaActualImagen = 0;

  final PageController _imageController = PageController();

  bool expandirPersonalizaciones = false;
  bool expandirBebidas = false;

  List<String> _opcionesPersonalizacion = [];
  Set<String> _personalizacionesSeleccionadas = {};

  List<OpcionExtraProducto> _listaBebidas = [];

  bool sinCebolla = false;
  bool sinLechuga = false;

  String? opcionBebida;
  double precioBebida = 0.0;

  @override
  void initState() {
    super.initState();
    _sincronizarDesdeWidget();
  }

  @override
  void didUpdateWidget(covariant ProductDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.personalizaciones != widget.personalizaciones ||
        oldWidget.bebidas != widget.bebidas ||
        oldWidget.name != widget.name) {
      _sincronizarDesdeWidget();
    }
  }

  void _sincronizarDesdeWidget() {
    cantidad = widget.initialCantidad;
    sinCebolla = widget.initialSinCebolla;
    sinLechuga = widget.initialSinLechuga;

    _opcionesPersonalizacion =
        List<String>.from(widget.personalizaciones);

    _personalizacionesSeleccionadas =
        Set<String>.from(widget.initialPersonalizaciones);

    if (sinCebolla &&
        _opcionesPersonalizacion.contains('Sin Cebolla')) {
      _personalizacionesSeleccionadas.add('Sin Cebolla');
    }

    if (sinLechuga &&
        _opcionesPersonalizacion.contains('Sin Lechuga')) {
      _personalizacionesSeleccionadas.add('Sin Lechuga');
    }

    _listaBebidas = List<OpcionExtraProducto>.from(widget.bebidas);

    opcionBebida = null;
    precioBebida = 0.0;

    if (widget.initialBebida != null) {
      final encontrada = _listaBebidas.where(
        (e) => e.nombre == widget.initialBebida,
      );

      if (encontrada.isNotEmpty) {
        opcionBebida = encontrada.first.nombre;
        precioBebida = encontrada.first.precio;
      }
    }
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryRed = Color(0xFF801414);
    const Color bgBeige = Color(0xFFFFF8EA);
    const Color orangeColor = Color(0xFFE06D1A);
    const Color darkText = Color(0xFF3E1F1F);

    double precioUnitarioTotal = widget.rawPrice + precioBebida;

    double precioTotal = precioUnitarioTotal * cantidad;

    final imagenProducto = widget.imageUrl.isEmpty
        ? 'assets/images/ha.jpg'
        : widget.imageUrl;

    final List<String> imagenesCarrusel =
        List.filled(3, imagenProducto);

    final int totalPersonalizaciones =
        _personalizacionesSeleccionadas.length;

    return Scaffold(
      backgroundColor: bgBeige,
      appBar: AppBar(
        backgroundColor: primaryRed,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            SizedBox(
              height: 220,
              child: PageView.builder(
                controller: _imageController,
                itemCount: imagenesCarrusel.length,
                onPageChanged: (i) {
                  setState(() => paginaActualImagen = i);
                },
                itemBuilder: (_, i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: imagenesCarrusel[i].startsWith('http')
                        ? Image.network(
                            imagenesCarrusel[i],
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Image.asset(
                              'assets/images/ha.jpg',
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.asset(
                            imagenesCarrusel[i],
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const Center(
                              child: Icon(Icons.broken_image_outlined),
                            ),
                          ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                imagenesCarrusel.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: paginaActualImagen == i ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: paginaActualImagen == i
                        ? primaryRed
                        : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              widget.price,
              style: const TextStyle(
                color: orangeColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              widget.name,
              style: const TextStyle(
                color: darkText,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              widget.description,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 15,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 24),

            // PERSONALIZACIONES
            _buildAccordionSection(
              title: 'Personalizaciones',
              subtitle: _opcionesPersonalizacion.isEmpty
                  ? 'Sin opciones configuradas en administración'
                  : 'Puedes seleccionar varias opciones',
              statusText: totalPersonalizaciones > 0 ? 'Listo' : null,
              isStatusGreen: true,
              isExpanded: expandirPersonalizaciones,
              onTap: () {
                setState(() {
                  expandirPersonalizaciones =
                      !expandirPersonalizaciones;
                });
              },
              children: _opcionesPersonalizacion.isEmpty
                  ? [
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'No hay personalizaciones configuradas para este producto.',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ]
                  : _opcionesPersonalizacion.map((opcion) {
                      final marcada =
                          _personalizacionesSeleccionadas.contains(opcion);

                      return CheckboxListTile(
                        title: Text(
                          opcion,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        value: marcada,
                        activeColor: orangeColor,
                        checkboxShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              _personalizacionesSeleccionadas.add(opcion);
                            } else {
                              _personalizacionesSeleccionadas.remove(opcion);
                            }

                            sinCebolla =
                                _personalizacionesSeleccionadas
                                    .contains('Sin Cebolla');

                            sinLechuga =
                                _personalizacionesSeleccionadas
                                    .contains('Sin Lechuga');
                          });
                        },
                      );
                    }).toList(),
            ),

            const SizedBox(height: 12),

            // BEBIDAS
            _buildAccordionSection(
              title: 'Bebida (segun disponibilidad)',
              subtitle: _listaBebidas.isEmpty
                  ? 'Sin bebidas configuradas en administración'
                  : 'Puedes seleccionar una opción disponible',
              statusText: opcionBebida != null ? 'Listo' : null,
              isStatusGreen: true,
              isExpanded: expandirBebidas,
              onTap: () {
                setState(() {
                  expandirBebidas = !expandirBebidas;
                });
              },
              children: _listaBebidas.isEmpty
                  ? [
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'No hay bebidas configuradas para este producto.',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ]
                  : _listaBebidas.map((bebida) {
                      final seleccionada =
                          opcionBebida == bebida.nombre;

                      return _buildSquareOption(
                        text: bebida.nombre,
                        priceText: bebida.precio > 0
                            ? '${bebida.precio.toStringAsFixed(0)} COP'
                            : 'Gratis',
                        isSelected: seleccionada,
                        onTap: () {
                          setState(() {
                            if (seleccionada) {
                              opcionBebida = null;
                              precioBebida = 0.0;
                            } else {
                              opcionBebida = bebida.nombre;
                              precioBebida = bebida.precio;
                            }
                          });
                        },
                      );
                    }).toList(),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),

      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 16),
                      onPressed: () {
                        if (cantidad > 1) {
                          setState(() => cantidad--);
                        }
                      },
                    ),

                    Text(
                      '$cantidad',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    IconButton(
                      icon: const Icon(Icons.add, size: 16),
                      onPressed: () {
                        setState(() => cantidad++);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              SizedBox(
                width: 175,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orangeColor,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    final listaPers =
                        _personalizacionesSeleccionadas.toList();

                    final itemActualizado = {
                      "nombre": widget.name,
                      "precio": precioUnitarioTotal.toInt(),
                      "cant": cantidad,
                      "icono": Icons.fastfood,
                      "imageUrl": widget.imageUrl,
                      "description": widget.description,
                      "rawPrice": widget.rawPrice,
                      "personalizaciones": listaPers,
                      "bebida": opcionBebida,
                      "sinCebolla": sinCebolla,
                      "sinLechuga": sinLechuga,
                    };

                    if (widget.onAgregarAlCarrito != null) {
                      widget.onAgregarAlCarrito!(itemActualizado);
                    } else {
                      Carrito.agregarItem(itemActualizado);
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '¡${widget.name} guardado en el carrito!',
                        ),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                      ),
                    );

                    Navigator.pop(context, itemActualizado);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.shopping_cart_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        precioTotal.toStringAsFixed(0),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSquareOption({
    required String text,
    required String priceText,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    const Color orangeColor = Color(0xFFE06D1A);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
            ),

            Text(
              priceText,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),

            const SizedBox(width: 12),

            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isSelected
                    ? orangeColor
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? orangeColor
                      : Colors.grey.shade600,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccordionSection({
    required String title,
    required String subtitle,
    required String? statusText,
    bool isStatusGreen = false,
    required bool isExpanded,
    required VoidCallback onTap,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            onTap: onTap,
            title: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E1F1F),
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (statusText != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isStatusGreen
                          ? Colors.green
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                if (statusText != null)
                  const SizedBox(width: 8),

                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.black87,
                ),
              ],
            ),
          ),

          if (isExpanded) ...[
            const Divider(height: 1),
            ...children,
          ],
        ],
      ),
    );
  }
}
