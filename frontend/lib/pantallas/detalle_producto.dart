import 'package:flutter/material.dart';
import 'package:elparchee/pantallas/carrito.dart'; // Asegúrate de importar tu archivo carrito.dart

class ProductDetailScreen extends StatefulWidget {
  final String title;
  final String imageUrl;
  final String price;
  final String name;
  final String description;
  final double rawPrice;
  final String? initialAcompanamiento;
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
    this.initialAcompanamiento,
    this.initialBebida,
    this.initialSinCebolla = false,
    this.initialSinLechuga = false,
    this.initialCantidad = 1,
    this.onAgregarAlCarrito,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late int cantidad;
  int paginaActualImagen = 0;
  final PageController _imageController = PageController();

  bool expandirPersonalizaciones = false;
  bool expandirAcompa = false;
  bool expandirBebidas = false;

  late bool sinCebolla;
  late bool sinLechuga;

  String? opcionAcompanamiento;
  double precioAcompanamiento = 0.0;

  String? opcionBebida;
  double precioBebida = 0.0;

  @override
  void initState() {
    super.initState();
    cantidad = widget.initialCantidad;
    sinCebolla = widget.initialSinCebolla;
    sinLechuga = widget.initialSinLechuga;

    // Cargar acompañamiento previo si existe
    if (widget.initialAcompanamiento != null) {
      opcionAcompanamiento = widget.initialAcompanamiento;
      if (opcionAcompanamiento == 'Papas en casco medianas') precioAcompanamiento = 3500.0;
      if (opcionAcompanamiento == 'Papas corral grandes') precioAcompanamiento = 5000.0;
      if (opcionAcompanamiento == 'Papas Espiral') precioAcompanamiento = 6000.0;
    }

    // Cargar bebida previa si existe
    if (widget.initialBebida != null) {
      opcionBebida = widget.initialBebida;
      if (opcionBebida == 'Gaseosa pepsi zero' || opcionBebida == 'Gaseosa pepsi') precioBebida = 4000.0;
      if (opcionBebida == 'Mr tea limon') precioBebida = 4500.0;
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

    double precioUnitarioTotal = widget.rawPrice + precioAcompanamiento + precioBebida;
    double precioTotal = precioUnitarioTotal * cantidad;

    final List<String> imagenesCarrusel = [
      'assets/images/ha.jpg',
      'assets/images/ha.jpg',
      'assets/images/ha.jpg',
    ];

    int totalPersonalizaciones = (sinCebolla ? 1 : 0) + (sinLechuga ? 1 : 0);

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

            // Carrusel de imágenes
            SizedBox(
              height: 220,
              child: PageView.builder(
                controller: _imageController,
                itemCount: imagenesCarrusel.length,
                onPageChanged: (i) => setState(() => paginaActualImagen = i),
                itemBuilder: (_, i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      imagenesCarrusel[i],
                      width: double.infinity,
                      fit: BoxFit.cover,
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

            // SECCIÓN: Personalizaciones
            _buildAccordionSection(
              title: 'Personalizaciones',
              subtitle: 'Puedes seleccionar varias opciones',
              statusText: totalPersonalizaciones > 0 ? 'Listo' : null,
              isStatusGreen: true,
              isExpanded: expandirPersonalizaciones,
              onTap: () => setState(() => expandirPersonalizaciones = !expandirPersonalizaciones),
              children: [
                CheckboxListTile(
                  title: const Text('Sin Cebolla', style: TextStyle(fontWeight: FontWeight.w500)),
                  value: sinCebolla,
                  activeColor: orangeColor,
                  checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  onChanged: (val) => setState(() => sinCebolla = val ?? false),
                ),
                CheckboxListTile(
                  title: const Text('Sin Lechuga', style: TextStyle(fontWeight: FontWeight.w500)),
                  value: sinLechuga,
                  activeColor: orangeColor,
                  checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  onChanged: (val) => setState(() => sinLechuga = val ?? false),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // SECCIÓN: Acompañamientos
            _buildAccordionSection(
              title: 'Acompanamientos',
              subtitle: 'Puedes seleccionar varias opciones',
              statusText: opcionAcompanamiento != null ? 'Listo' : null,
              isStatusGreen: true,
              isExpanded: expandirAcompa,
              onTap: () => setState(() => expandirAcompa = !expandirAcompa),
              children: [
                _buildSquareOption(
                  text: 'Papas en casco medianas',
                  priceText: '3,500 COP',
                  isSelected: opcionAcompanamiento == 'Papas en casco medianas',
                  onTap: () {
                    setState(() {
                      if (opcionAcompanamiento == 'Papas en casco medianas') {
                        opcionAcompanamiento = null;
                        precioAcompanamiento = 0.0;
                      } else {
                        opcionAcompanamiento = 'Papas en casco medianas';
                        precioAcompanamiento = 3500.0;
                      }
                    });
                  },
                ),
                _buildSquareOption(
                  text: 'Papas corral grandes',
                  priceText: '5,000 COP',
                  isSelected: opcionAcompanamiento == 'Papas corral grandes',
                  onTap: () {
                    setState(() {
                      if (opcionAcompanamiento == 'Papas corral grandes') {
                        opcionAcompanamiento = null;
                        precioAcompanamiento = 0.0;
                      } else {
                        opcionAcompanamiento = 'Papas corral grandes';
                        precioAcompanamiento = 5000.0;
                      }
                    });
                  },
                ),
                _buildSquareOption(
                  text: 'Papas Espiral',
                  priceText: '6,000 COP',
                  isSelected: opcionAcompanamiento == 'Papas Espiral',
                  onTap: () {
                    setState(() {
                      if (opcionAcompanamiento == 'Papas Espiral') {
                        opcionAcompanamiento = null;
                        precioAcompanamiento = 0.0;
                      } else {
                        opcionAcompanamiento = 'Papas Espiral';
                        precioAcompanamiento = 6000.0;
                      }
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // SECCIÓN: Bebida
            _buildAccordionSection(
              title: 'Bebida (segun disponibilidad)',
              subtitle: 'Puedes seleccionar varias opciones',
              statusText: opcionBebida != null ? 'Listo' : null,
              isStatusGreen: true,
              isExpanded: expandirBebidas,
              onTap: () => setState(() => expandirBebidas = !expandirBebidas),
              children: [
                _buildSquareOption(
                  text: 'Gaseosa pepsi zero',
                  priceText: '4,000 COP',
                  isSelected: opcionBebida == 'Gaseosa pepsi zero',
                  onTap: () {
                    setState(() {
                      if (opcionBebida == 'Gaseosa pepsi zero') {
                        opcionBebida = null;
                        precioBebida = 0.0;
                      } else {
                        opcionBebida = 'Gaseosa pepsi zero';
                        precioBebida = 4000.0;
                      }
                    });
                  },
                ),
                _buildSquareOption(
                  text: 'Gaseosa pepsi',
                  priceText: '4,000 COP',
                  isSelected: opcionBebida == 'Gaseosa pepsi',
                  onTap: () {
                    setState(() {
                      if (opcionBebida == 'Gaseosa pepsi') {
                        opcionBebida = null;
                        precioBebida = 0.0;
                      } else {
                        opcionBebida = 'Gaseosa pepsi';
                        precioBebida = 4000.0;
                      }
                    });
                  },
                ),
                _buildSquareOption(
                  text: 'Mr tea limon',
                  priceText: '4,500 COP',
                  isSelected: opcionBebida == 'Mr tea limon',
                  onTap: () {
                    setState(() {
                      if (opcionBebida == 'Mr tea limon') {
                        opcionBebida = null;
                        precioBebida = 0.0;
                      } else {
                        opcionBebida = 'Mr tea limon';
                        precioBebida = 4500.0;
                      }
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),

      // Botón Inferior: Retorna y guarda la información en el Carrito global
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -3))
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
                        if (cantidad > 1) setState(() => cantidad--);
                      },
                    ),
                    Text(
                      '$cantidad',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 16),
                      onPressed: () => setState(() => cantidad++),
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
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    final itemActualizado = {
                      "nombre": widget.name,
                      "precio": precioUnitarioTotal.toInt(),
                      "cant": cantidad,
                      "icono": Icons.fastfood,
                      "imageUrl": widget.imageUrl,
                      "description": widget.description,
                      "rawPrice": widget.rawPrice,
                      "acompanamiento": opcionAcompanamiento,
                      "bebida": opcionBebida,
                      "sinCebolla": sinCebolla,
                      "sinLechuga": sinLechuga,
                    };

                    // Guardamos el producto usando la función global del carrito
                    Carrito.agregarItem(itemActualizado);

                    if (widget.onAgregarAlCarrito != null) {
                      widget.onAgregarAlCarrito!(itemActualizado);
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('¡${widget.name} guardado en el carrito!'),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                      ),
                    );

                    Navigator.pop(context, itemActualizado);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '${precioTotal.toStringAsFixed(0)}',
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),
            ),
            Text(
              priceText,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700]),
            ),
            const SizedBox(width: 12),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isSelected ? orangeColor : Colors.transparent,
                border: Border.all(
                  color: isSelected ? orangeColor : Colors.grey.shade600,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
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
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        children: [
          ListTile(
            onTap: onTap,
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3E1F1F), fontSize: 16),
            ),
            subtitle: Text(
              subtitle,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (statusText != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isStatusGreen ? Colors.green : Colors.transparent,
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
                if (statusText != null) const SizedBox(width: 8),
                Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.black87),
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