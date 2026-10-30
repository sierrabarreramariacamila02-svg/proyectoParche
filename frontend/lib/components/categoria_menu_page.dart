import 'package:flutter/material.dart';
import '../models/producto_model.dart';
import '../services/producto_service.dart';
import 'package:elparchee/app_colors.dart';
import '../services/cart_service.dart';

class CategoriaMenuPage extends StatefulWidget {
  final String tituloCategoria;
  final String filtroBackend;

  const CategoriaMenuPage({
    super.key,
    required this.tituloCategoria,
    required this.filtroBackend,
  });

  @override
  State<CategoriaMenuPage> createState() => _CategoriaMenuPageState();
}

class _CategoriaMenuPageState extends State<CategoriaMenuPage> {
  static const Color brand = AppColors.barraHome;
  final ProductoService _productoService = ProductoService();
  late Future<List<ProductoModel>> _futureProductos;

  @override
  void initState() {
    super.initState();
    // Llama al servicio pidiendo únicamente los productos de esta categoría
    _futureProductos = _productoService.obtenerProductos(categoria: widget.filtroBackend);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera con el estilo rojo de tu app
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: brand,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.tituloCategoria,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            // Listado de productos que creó el administrador
            Expanded(
              child: FutureBuilder<List<ProductoModel>>(
                future: _futureProductos,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: brand));
                  }
                  
                  final productos = snapshot.data ?? [];
                  if (productos.isEmpty) {
                    return const Center(
                      child: Text(
                        'No hay productos registrados en esta categoría.',
                        style: TextStyle(color: Colors.black54),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: productos.length,
                    itemBuilder: (context, index) {
                      final p = productos[index];
                      return Card(
                        color: AppColors.inputBackground,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(
                            p.nombre,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(p.descripcion),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '\$${p.precio.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: brand,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              IconButton(
                                tooltip: 'Agregar al carrito',
                                onPressed: () {
                                  CartService.instance.add(p);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${p.nombre} agregado al carrito',
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.add_shopping_cart),
                                color: brand,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}