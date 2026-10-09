import 'package:elparchee/pantallas/carrito.dart';
<<<<<<< Updated upstream
=======
import 'package:elparchee/pantallas/menuHamburguesas.dart';
import 'package:elparchee/pantallas/menuOtros.dart';
import 'package:elparchee/pantallas/menuPerro.dart';
import 'package:elparchee/pantallas/menuSalchipapa.dart';
>>>>>>> Stashed changes
import 'package:flutter/material.dart';
import 'package:elparchee/app_colors.dart';

class Productos extends StatefulWidget {
  const Productos({super.key});
  @override
  State<Productos> createState() => _ProductosState();
}

class _ProductosState extends State<Productos> {
  final PageController _controller = PageController();
  int paginaActual = 0, _indiceIcono = 0, _indiceFiltro = 0;

  final List<String> imagenes = [
    'assets/images/promo1.png',
    'assets/images/promo2.png',
    'assets/images/promo3.png', 
  ];
  final List<String> platos = [
    'assets/images/plato1.png',
    'assets/images/plato2.png',
    'assets/images/plato3.png',
    'assets/images/plato4.png',
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
            onPressed: () {},
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
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: paginaActual == i ? 18 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: paginaActual == i
                        ? AppColors.barraHome
                        : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            // CATEGORÍAS CON IMÁGENES CLICKEABLES
            _titulo('Categorías populares'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _categorias
                  .map(
                    (c) => _catItem(
                      c['img']!,
                      c['lbl']!,
                      c['color'] as Color,
                      () => print('Tocó ${c['lbl']}'),
                    ),
                  )
                  .toList(),
            ),

            _titulo('Platos destacados.'),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: platos.length,
              itemBuilder: (_, i) => Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.asset(
                          platos[i],
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Producto',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '12,000 COP',
                            style: TextStyle(
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
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),

      // BOTTOM NAVIGATION BAR CON SAFEAREA Y CARRITO SOBRESALIDO
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
                    clipBehavior: Clip.none, // Permite sobresalir al carrito
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
                        top: -24, // Eleva el botón del carrito
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
                                MaterialPageRoute(builder: (_) => const Carrito()),
                              );
                            },
                            
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // BARRA DE FILTROS
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
                          onTap: () => setState(() => _indiceFiltro = i),
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

  // WIDGETS AUXILIARES
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
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
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
    onPressed: () => setState(() => _indiceIcono = index),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
