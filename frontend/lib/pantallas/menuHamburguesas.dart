import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:intl/intl.dart'; // 👈 Importante para formatear el precio limpio
import 'package:elparchee/app_colors.dart';
import '../services/producto_service.dart'; // 👈 Tu servicio
import '../models/producto_model.dart';       // 👈 Tu modelo

class MenuHamburguesas extends StatefulWidget {
  const MenuHamburguesas({super.key});

  @override
  State<MenuHamburguesas> createState() => _MenuHamburguesasState();
}

class _MenuHamburguesasState extends State<MenuHamburguesas> {
  // 1. Instanciamos el servicio y declaramos el Future para la lista
  final ProductoService _productoService = ProductoService();
  late Future<List<ProductoModel>> _futureHamburguesas;

  String _query = '';

  @override
  void initState() {
    super.initState();
    // 2. Cargamos las hamburguesas filtrando exactamente por la categoría del panel admin
    _futureHamburguesas = _productoService.obtenerProductos(categoria: 'Hamburguesas');
  }

  @override
  Widget build(BuildContext context) {
    final formatoMoneda = NumberFormat('#,###', 'es_CO');

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            _MenuHeader(
              title: 'Hamburguesas',
              onBack: () => Navigator.pop(context),
              onSearchChanged: (text) => setState(() => _query = text),
            ),
            Expanded(
              // 3. Usamos FutureBuilder para manejar la carga de datos del servidor y Cloudinary
              child: FutureBuilder<List<ProductoModel>>(
                future: _futureHamburguesas,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No hay hamburguesas registradas'));
                  }

                  // Obtenemos los productos y filtramos por la barra de búsqueda si el usuario escribe
                  final productos = snapshot.data!;
                  final filtered = productos
                      .where((e) => e.nombre
                          .toLowerCase()
                          .contains(_query.trim().toLowerCase()))
                      .toList();

                  if (filtered.isEmpty) {
                    return const Center(child: Text('No encontramos esa hamburguesa'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final item = filtered[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.barraInferior,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 4),
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            // 4. Imagen dinámica desde Cloudinary con respaldo si no tiene
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: item.imagenUrl.isNotEmpty
                                  ? Image.network(
                                      item.imagenUrl,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.fastfood, size: 40, color: Colors.orange),
                                    )
                                  : const Icon(Icons.fastfood, size: 50, color: Colors.orange),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.nombre,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    item.descripcion,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // 5. Precio formateado visualmente con puntos (ej: $ 14.000)
                                      Text(
                                        '\$ ${formatoMoneda.format(item.precio)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF7A1C1C),
                                          fontSize: 15,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove,
                                                size: 18),
                                            onPressed: () {},
                                          ),
                                          const Text(
                                            '1',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.add,
                                                size: 18),
                                            onPressed: () {},
                                          ),
                                          ElevatedButton(
                                            onPressed: () {},
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFF7A1C1C),
                                              shadowColor: Colors.black12,
                                              elevation: 4,
                                            ),
                                            child: const Text(
                                              'Añadir',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          backgroundColor: AppColors.buttonOrange,
          icon: const Icon(Icons.shopping_cart, color: Colors.white),
          label: const Text(
            'Ver mi Pedido',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

// Clases de Header y Botones se mantienen exactamente igual abajo...
class _MenuHeader extends StatelessWidget {
  const _MenuHeader({
    required this.title,
    required this.onBack,
    required this.onSearchChanged,
  });

  final String title;
  final VoidCallback onBack;
  final ValueChanged<String> onSearchChanged;

  static const double _searchHeight = 46;
  static const double _overlap = _searchHeight / 2;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Padding(
      padding: const EdgeInsets.only(bottom: _overlap),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16, topInset + 12, 16, _overlap + 20),
            decoration: const BoxDecoration(
              color: AppColors.barraHome,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _CircleButton(
                      icon: Icons.arrow_back_rounded,
                      background: const Color.fromRGBO(248, 242, 228, 0.16),
                      foreground: AppColors.background,
                      tooltip: 'Volver',
                      onTap: onBack,
                    ),
                    const _CircleButton(
                      icon: Icons.lunch_dining,
                      background: AppColors.background,
                      foreground: AppColors.barraHome,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 30,
                    height: 1.1,
                    color: AppColors.background,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: -_overlap,
            child: Container(
              height: _searchHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.inputBackground, width: 1),
              ),
              child: TextField(
                onChanged: onSearchChanged,
                cursorColor: AppColors.barraHome,
                textInputAction: TextInputAction.search,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Buscar hamburguesa',
                  hintStyle: TextStyle(color: Colors.black45, fontSize: 14),
                  prefixIcon: Icon(Icons.search_rounded, color: Colors.black45),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.background,
    required this.foreground,
    this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback? onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: background,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: foreground, size: 22),
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}