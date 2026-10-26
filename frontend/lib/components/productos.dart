import 'package:elparchee/app_colors.dart';
import 'package:elparchee/pantallas/buscar.dart';
import 'package:elparchee/pantallas/carrito.dart';
import 'package:elparchee/pantallas/pedidos.dart';
import 'package:elparchee/pantallas/perfil.dart';
import 'package:elparchee/pantallas/menuHamburguesas.dart';
import 'package:elparchee/pantallas/menuOtros.dart';
import 'package:elparchee/pantallas/menuPerro.dart';
import 'package:elparchee/pantallas/menuSalchipapa.dart';
import 'package:elparchee/pantallas/notificaciones.dart'; // <-- Importado
import 'package:elparchee/models/producto_model.dart';
import 'package:elparchee/services/producto_service.dart';
import 'package:flutter/material.dart';

class Productos extends StatefulWidget {
  const Productos({super.key});

  @override
  State<Productos> createState() => _ProductosState();
}

class _ProductosState extends State<Productos> {
  final PageController _controller = PageController();
  final ProductoService _productoService = ProductoService();

  int paginaActual = 0;
  int _indiceIcono = 0;
  int _indiceFiltro = 0;

  List<ProductoModel> _listaProductos = [];
  bool _isLoading = true;
  String? _errorCarga;

  final List<String> imagenes = [
    'assets/images/promo1.png',
    'assets/images/promo2.png',
    'assets/images/promo3.png',
  ];

  final List<String> _filtros = [
    'Productos destacados',
    'Perros calientes y mas',
    'Bebidas',
  ];

  final List<Map<String, dynamic>> _categorias = [
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
    _cargarProductosHome();
  }

  Future<void> _cargarProductosHome() async {
    setState(() {
      _isLoading = true;
      _errorCarga = null;
    });
    try {
      final productos = await _productoService.obtenerProductos();
      if (!mounted) return;
      setState(() {
        _listaProductos = productos;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorCarga = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  List<ProductoModel> get _productosFiltrados {
    if (_indiceFiltro == 0) {
      return _listaProductos;
    } else if (_indiceFiltro == 1) {
      return _listaProductos
          .where((p) => p.categoria.toLowerCase().contains('perro'))
          .toList();
    } else {
      return _listaProductos
          .where(
            (p) =>
                p.categoria.toLowerCase().contains('bebida') ||
                p.categoria.toLowerCase().contains('otro'),
          )
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF3E0),
      appBar: AppBar(
        backgroundColor: AppColors.barraHome,
        title: const Text(
          'Hola username!',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _titulo('Promociones y descuentos!'),
            SizedBox(
              height: 200,
              child: PageView.builder(
                controller: _controller,
                itemCount: imagenes.length,
                onPageChanged: (i) => setState(() => paginaActual = i),
                itemBuilder: (_, i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(45),
                    child: Image.asset(imagenes[i], fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                imagenes.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: paginaActual == i ? 18 : 8,
                  height: 10,
                  decoration: BoxDecoration(
                    color: paginaActual == i
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
              children: _categorias.map((c) {
                final lbl = c['lbl'] as String;
                return _catItem(
                  c['img'] as String,
                  lbl,
                  c['color'] as Color,
                  () {
                    if (lbl == 'Perros calientes') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MenuPerro(),
                        ),
                      );
                    } else if (lbl == 'Hamburguesas') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MenuHamburguesas(),
                        ),
                      );
                    } else if (lbl == 'Salchipapas') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SalchipapasMenu(),
                        ),
                      );
                    } else if (lbl == 'Otros') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MenuOtros(),
                        ),
                      );
                    }
                  },
                );
              }).toList(),
            ),
            _titulo(_filtros[_indiceFiltro]),
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
            else if (_productosFiltrados.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('No hay productos en esta categoría.'),
                ),
              )
            else
              _buildProductGrid(_productosFiltrados),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: AppColors.barraInferior,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
              top: 12,
              bottom: 8,
              left: 16,
              right: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 30,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _navIcon(Icons.home_outlined, 0),
                          _navIcon(Icons.search, 1),
                          const SizedBox(width: 50),
                          _navIcon(Icons.receipt_long_outlined, 2),
                          _navIcon(Icons.person_outline, 3),
                        ],
                      ),
                      Positioned(
                        top: -24,
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.buttonOrange,
                          child: IconButton(
                            icon: const Icon(
                              Icons.shopping_cart_outlined,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const Carrito(),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.barraInferior,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: List.generate(
                      _filtros.length,
                      (i) => Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _indiceFiltro = i);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _indiceFiltro == i
                                  ? AppColors.buttonOrange
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Text(
                              _filtros[i],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _indiceFiltro == i
                                    ? Colors.black
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductGrid(List<ProductoModel> productos) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: productos.length,
      itemBuilder: (_, i) {
        final producto = productos[i];
        return Card(
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
        );
      },
    );
  }

  Widget _titulo(String t) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
    child: Text(
      t,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.barraHome,
      ),
    ),
  );

  Widget _catItem(
    String img,
    String lbl,
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
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(img, fit: BoxFit.contain),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          lbl,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
        ),
      ],
    ),
  );

  Widget _navIcon(IconData icon, int index) => IconButton(
    icon: Icon(
      icon,
      color: _indiceIcono == index ? AppColors.barraHome : Colors.brown,
    ),
    onPressed: () {
      setState(() => _indiceIcono = index);
      final Widget? pagina = switch (index) {
        1 => const Buscar(),
        2 => const Pedidos(),
        3 => const Perfil(),
        _ => null,
      };
      if (pagina != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => pagina),
        );
      }
    },
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}