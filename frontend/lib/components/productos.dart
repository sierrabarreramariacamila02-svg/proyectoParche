import 'package:elparchee/app_colors.dart';
import 'package:elparchee/components/customer_bottom_navigation.dart';
import 'package:elparchee/models/producto_model.dart';
import 'package:elparchee/pantallas/detalle_producto.dart';
import 'package:elparchee/pantallas/notificaciones.dart';
import 'package:elparchee/services/cart_service.dart';
import 'package:elparchee/services/destacado_service.dart';
import 'package:elparchee/services/producto_service.dart'; // 👈 Asegúrate de tener tu servicio de productos importado
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'admin_drawer.dart';

class Productos extends StatefulWidget {
  final bool isAdmin;

  const Productos({super.key, this.isAdmin = false});

  @override
  State<Productos> createState() => _ProductosState();
}

class _ProductosState extends State<Productos> {
  final PageController _controller = PageController();
  int _paginaActual = 0;
  List<ProductoModel> _listaDestacados = [];
  bool _isLoading = true;
  String? _errorCarga;
  String _nombreUsuario = 'username';
  String _correoUsuario = '';

  final List<String> _imagenes = [
    'assets/images/promo1.png',
    'assets/images/promo2.png',
    'assets/images/promo3.png',
  ];

  final List<Map<String, Object>> _categorias = [
    {
      'img': 'assets/images/hamburguesa.png',
      'lbl': 'Hamburguesas',
      'color': AppColors.inputBackground,
    },
    {
      'img': 'assets/images/perro.png',
      'lbl': 'Perros calientes',
      'color': AppColors.inputBackground,
    },
    {
      'img': 'assets/images/salchipapa.png',
      'lbl': 'Salchipapas',
      'color': AppColors.inputBackground,
    },
    {
      'img': 'assets/images/otros.png',
      'lbl': 'Otros',
      'color': AppColors.inputBackground,
    },
  ];

  @override
  void initState() {
    super.initState();
    DestacadoService.cambios.addListener(_alCambiarDestacados);
    _cargarProductosHome();
    if (widget.isAdmin) _cargarDatosAdmin();
  }

  Future<void> _cargarDatosAdmin() async {
    final preferencias = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _nombreUsuario = preferencias.getString('user_name') ?? 'Administrador';
      _correoUsuario = preferencias.getString('user_email') ?? '';
    });
  }

  void _alCambiarDestacados() {
    if (mounted) _cargarProductosHome();
  }

  Future<void> _cargarProductosHome() async {
    setState(() {
      _isLoading = true;
      _errorCarga = null;
    });
    try {
      final lista = await DestacadoService.obtener();
      if (!mounted) return;
      setState(() {
        _listaDestacados = lista
            .map((destacado) => destacado.toProducto())
            .toList();
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorCarga = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  // 🛠️ MODIFICADO: Ahora en lugar de abrir una página genérica de categoría vacía,
  // consultamos los productos de esa categoría y los mostramos con la misma estructura interactiva.
  void _abrirCategoria(String nombreCategoria) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _DetalleCategoriaScreen(tituloCategoria: nombreCategoria),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF3E0),
      appBar: AppBar(
        backgroundColor: AppColors.barraHome,
        title: Text(
          widget.isAdmin ? 'Hola, $_nombreUsuario' : 'Hola username!',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Notificaciones()),
              );
            },
          ),
        ],
      ),
      drawer: widget.isAdmin
          ? AdminDrawer(adminName: _nombreUsuario, adminEmail: _correoUsuario)
          : null,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _titulo('Promociones y descuentos!'),
            SizedBox(
              height: 200,
              child: PageView.builder(
                controller: _controller,
                itemCount: _imagenes.length,
                onPageChanged: (index) => setState(() => _paginaActual = index),
                itemBuilder: (_, index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(45),
                    child: Image.asset(_imagenes[index], fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _imagenes.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _paginaActual == index ? 18 : 8,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _paginaActual == index
                        ? AppColors.barraHome
                        : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            _titulo('Menú.'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _categorias.map((categoria) {
                final nombre = categoria['lbl']! as String;
                return _catItem(
                  categoria['img']! as String,
                  nombre,
                  categoria['color']! as Color,
                  () => _abrirCategoria(nombre),
                );
              }).toList(),
            ),
            _titulo('Productos destacados'),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_errorCarga != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        'No se pudieron cargar los productos: $_errorCarga',
                        textAlign: TextAlign.center,
                      ),
                      TextButton(
                        onPressed: _cargarProductosHome,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_listaDestacados.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('No hay productos destacados disponibles.'),
                ),
              )
            else
              _buildProductGrid(_listaDestacados),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: const CustomerBottomNavigation(selectedIndex: 0),
    );
  }

  Widget _buildProductGrid(List<ProductoModel> productos) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: productos.length,
      itemBuilder: (_, index) {
        final producto = productos[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailScreen(
                  title: 'Detalle del producto',
                  imageUrl: producto.imagenUrl,
                  price: '\$${producto.precio.toStringAsFixed(0)} COP',
                  name: producto.nombre,
                  description: producto.descripcion,
                  rawPrice: producto.precio,
                  onAgregarAlCarrito: (item) {
                    CartService.instance.add(
                      producto,
                      quantity: item['cant'] as int? ?? 1,
                    );
                  },
                ),
              ),
            );
          },
          child: Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: producto.imagenUrl.isEmpty
                      ? const Center(
                          child: Icon(
                            Icons.fastfood,
                            size: 48,
                            color: Colors.grey,
                          ),
                        )
                      : Image.network(
                          producto.imagenUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (_, _, _) => const Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              size: 48,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        producto.nombre,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '\$${producto.precio.toStringAsFixed(0)} COP',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.buttonOrange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _titulo(String texto) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
    child: Text(
      texto,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.barraHome,
      ),
    ),
  );

  Widget _catItem(
    String imagen,
    String nombre,
    Color colorFondo,
    VoidCallback onTap,
  ) => GestureDetector(
    onTap: onTap,
    child: Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: colorFondo,
            shape: BoxShape.circle,
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: ClipOval(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Image.asset(imagen, fit: BoxFit.contain),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          nombre,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
        ),
      ],
    ),
  );

  @override
  void dispose() {
    DestacadoService.cambios.removeListener(_alCambiarDestacados);
    _controller.dispose();
    super.dispose();
  }
}

// ----------------------------------------------------------------------
// Widget interno para mostrar los productos de la categoría seleccionada
// con la misma estructura y diseño de detalle que la primera imagen.
// ----------------------------------------------------------------------
class _DetalleCategoriaScreen extends StatefulWidget {
  final String tituloCategoria;

  const _DetalleCategoriaScreen({required this.tituloCategoria});

  @override
  State<_DetalleCategoriaScreen> createState() => _DetalleCategoriaScreenState();
}

class _DetalleCategoriaScreenState extends State<_DetalleCategoriaScreen> {
  final ProductoService _productoService = ProductoService();
  late Future<List<ProductoModel>> _futureProductos;

  @override
  void initState() {
    super.initState();
    _futureProductos = _productoService.obtenerProductos(categoria: widget.tituloCategoria);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF3E0),
      appBar: AppBar(
        backgroundColor: AppColors.barraHome,
        title: Text(
          widget.tituloCategoria,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<ProductoModel>>(
        future: _futureProductos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error al cargar: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay productos en esta categoría'));
          }

          final productos = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.72,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: productos.length,
            itemBuilder: (_, index) {
              final producto = productos[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(
                        title: widget.tituloCategoria,
                        imageUrl: producto.imagenUrl,
                        price: '\$${producto.precio.toStringAsFixed(0)} COP',
                        name: producto.nombre,
                        description: producto.descripcion,
                        rawPrice: producto.precio,
                        onAgregarAlCarrito: (item) {
                          CartService.instance.add(
                            producto,
                            quantity: item['cant'] as int? ?? 1,
                          );
                        },
                      ),
                    ),
                  );
                },
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: producto.imagenUrl.isEmpty
                            ? const Center(
                                child: Icon(
                                  Icons.fastfood,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                              )
                            : Image.network(
                                producto.imagenUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (_, _, _) => const Center(
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              producto.nombre,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '\$${producto.precio.toStringAsFixed(0)} COP',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.buttonOrange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}