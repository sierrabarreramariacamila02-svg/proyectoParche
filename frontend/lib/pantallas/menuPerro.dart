import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:elparchee/app_colors.dart';
import 'package:elparchee/models/producto_model.dart';
import 'package:elparchee/pantallas/detalle_producto.dart';
import 'package:elparchee/services/producto_service.dart';
import 'package:elparchee/components/menu_helpers.dart';

const Color _wine = Color(0xFF7A1C1C);
const Color _cream = Color(0xFFF2E6D8);

class MenuPerro extends StatefulWidget {
  const MenuPerro({super.key});

  @override
  State<MenuPerro> createState() => _MenuPerroState();
}

class _MenuPerroState extends State<MenuPerro> {
  final ProductoService _productoService = ProductoService();
  List<Map<String, dynamic>> items = [];
  bool _cargando = true;
  String? _error;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    try {
      final todos = await _productoService.obtenerProductos();
      final productos = todos
          .where((p) => p.categoria == 'Perros calientes')
          .toList();

      if (!mounted) return;
      setState(() {
        items = productos
            .map(
              (p) => {
                'title': p.nombre,
                'desc': p.descripcion,
                'price': formatearPrecio(p.precio),
                'qty': 1,
                'imagen': p.imagenUrl,
                'producto': p,
              },
            )
            .toList();
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  void _abrirDetalle(Map<String, dynamic> item) {
    final ProductoModel? prod = item['producto'] as ProductoModel?;
    if (prod == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(
          title: prod.categoria.isNotEmpty
              ? prod.categoria
              : 'Perros calientes',
          imageUrl: prod.imagenUrl,
          price: item['price'] as String,
          name: prod.nombre,
          description: prod.descripcion,
          rawPrice: prod.precio,
          personalizaciones: prod.personalizaciones,
          bebidas: prod.bebidas,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = items
        .where(
          (e) => (e['title'] as String).toLowerCase().contains(
            _query.trim().toLowerCase(),
          ),
        )
        .toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.inputBackground,
        body: Column(
          children: [
            _MenuHeader(
              title: 'Perros calientes',
              searchHint: 'Buscar perro',
              onBack: () => Navigator.pop(context),
              onSearchChanged: (text) => setState(() => _query = text),
            ),
            Expanded(
              child: _cargando
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF7A1C1C),
                      ),
                    )
                  : _error != null
                  ? Center(child: Text(_error!))
                  : filtered.isEmpty
                  ? const Center(child: Text('No hay perros calientes todavía'))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                      itemCount: filtered.length,
                      itemBuilder: (context, i) {
                        final item = filtered[i];
                        return InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: () => _abrirDetalle(item),
                          child: Container(
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
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                ImagenProducto(
                                  url: item['imagen'] ?? '',
                                  icono: Icons.lunch_dining_outlined,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['title'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      Text(
                                        item['desc'],
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
                                          Text(
                                            item['price'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF7A1C1C),
                                              fontSize: 15,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.remove,
                                                  size: 18,
                                                ),
                                                onPressed: () => setState(() {
                                                  if (item['qty'] > 1) {
                                                    item['qty']--;
                                                  }
                                                }),
                                              ),
                                              Text(
                                                '${item['qty']}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.add,
                                                  size: 18,
                                                ),
                                                onPressed: () => setState(
                                                  () => item['qty']++,
                                                ),
                                              ),
                                              ElevatedButton(
                                                onPressed: () =>
                                                    _abrirDetalle(item),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(
                                                    0xFF7A1C1C,
                                                  ),
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
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          backgroundColor: const Color(0xFF7A1C1C),
          icon: const Icon(Icons.shopping_cart, color: Colors.white),
          label: const Text(
            'Ver mi Pedido',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class _MenuHeader extends StatelessWidget {
  const _MenuHeader({
    required this.title,
    required this.searchHint,
    required this.onBack,
    required this.onSearchChanged,
  });

  final String title;
  final String searchHint;
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
              color: _wine,
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
                      background: const Color.fromRGBO(242, 230, 216, 0.16),
                      foreground: _cream,
                      tooltip: 'Volver',
                      onTap: onBack,
                    ),
                    const _CircleButton(
                      icon: Icons.lunch_dining_outlined,
                      background: _cream,
                      foreground: _wine,
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
                    color: _cream,
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
                border: Border.all(color: _cream, width: 1),
              ),
              child: TextField(
                onChanged: onSearchChanged,
                cursorColor: _wine,
                textInputAction: TextInputAction.search,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: searchHint,
                  hintStyle: const TextStyle(
                    color: Colors.black45,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Colors.black45,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 13),
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
