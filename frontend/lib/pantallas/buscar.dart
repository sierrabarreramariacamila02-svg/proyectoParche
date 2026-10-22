import 'package:flutter/material.dart';
import 'package:elparchee/app_colors.dart';
import 'package:elparchee/components/productos.dart';
import 'package:elparchee/pantallas/carrito.dart';
import 'package:elparchee/pantallas/pedidos.dart';
import 'package:elparchee/pantallas/perfil.dart';

class Buscar extends StatefulWidget {
  const Buscar({super.key});

  @override
  State<Buscar> createState() => _BuscarState();
}

class _BuscarState extends State<Buscar> {
  int _indiceFiltro = 0;
  List<String> searches = [
    'Combo Familiar',
    'Hamburguesa clásica',
    'Papas grandes',
    'Bebida',
    'Perros calientes',
    'Postres'
  ];

  final List<String> _filtros = [
    'Productos destacados',
    'Perros calientes y mas',
    'Bebidas',
  ];

  @override
  Widget build(BuildContext context) {
    const red = AppColors.barraHome;
    const orange = AppColors.buttonOrange;
    const bg = Color(0xFFFAF6EE);
    const cardBg = Color(0xFFF2EAD8);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: red,
        title: const Text('Buscar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: const [Icon(Icons.notifications_none, color: Colors.white), SizedBox(width: 16)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: Icon(Icons.search, size: 45, color: orange)),
            const Center(
              child: Text(
                '¿QUÉ TE APETECE\nENCONTRAR?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
            ),
            const Center(child: Text('Busca tus platos favoritos', style: TextStyle(color: Colors.grey, fontSize: 13))),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(25)),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Busca por nombre de producto, categoría...',
                  prefixIcon: Icon(Icons.search, color: orange),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildHeader('Categorías', 'Ver todas >', () {}, red, orange),
            SizedBox(
              height: 85,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  _CatItem('Hamburguesas', Icons.lunch_dining, cardBg),
                  _CatItem('Papas y\nacompañamientos', Icons.fastfood, cardBg),
                  _CatItem('Perros calientes', Icons.fastfood_outlined, cardBg),
                  _CatItem('Bebidas', Icons.local_drink, cardBg),
                  _CatItem('Postres', Icons.cake, cardBg),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildHeader('Búsquedas recientes', 'Limpiar 🗑️', () => setState(() => searches.clear()), red, orange),
            Wrap(
              spacing: 6,
              children: searches
                  .map((s) => Chip(
                        backgroundColor: cardBg,
                        label: Text(s, style: const TextStyle(fontSize: 11)),
                        deleteIcon: const Icon(Icons.close, size: 13),
                        onDeleted: () => setState(() => searches.remove(s)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFF3C082), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('¿No encuentras\nlo que buscas?', style: TextStyle(fontWeight: FontWeight.bold, color: red)),
                        const Text('Prueba con otras palabras ⤴', style: TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
                  Icon(Icons.fastfood, size: 40, color: red),
                ],
              ),
            ),
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
                          IconButton(
                            icon: const Icon(Icons.home_outlined, color: Colors.brown),
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const Productos()),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.search, color: AppColors.barraHome),
                            onPressed: () {},
                          ),
                          const SizedBox(width: 50),
                          IconButton(
                            icon: const Icon(Icons.receipt_long_outlined, color: Colors.brown),
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const Pedidos()),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.person_outline, color: Colors.brown),
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const Perfil()),
                              );
                            },
                          ),
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

  Widget _buildHeader(String title, String action, VoidCallback onTap, Color red, Color orange) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: red)),
        GestureDetector(onTap: onTap, child: Text(action, style: TextStyle(color: orange, fontSize: 12))),
      ],
    );
  }
}

class _CatItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color cardBg;
  const _CatItem(this.title, this.icon, this.cardBg);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.brown),
          ),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 9)),
        ],
      ),
    );
  }
}