import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../components/customer_bottom_navigation.dart';
import '../models/producto_model.dart';
import '../services/cart_service.dart';
import '../services/producto_service.dart';

class Buscar extends StatefulWidget {
  const Buscar({super.key});

  @override
  State<Buscar> createState() => _BuscarState();
}

class _BuscarState extends State<Buscar> {
  final TextEditingController _searchController = TextEditingController();
  final ProductoService _productosService = ProductoService();
  late Future<List<ProductoModel>> _productosFuture;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _productosFuture = _productosService.obtenerProductos();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _recargar() {
    setState(() {
      _productosFuture = _productosService.obtenerProductos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6EE),
      appBar: AppBar(
        backgroundColor: AppColors.barraHome,
        foregroundColor: Colors.white,
        title: const Text('Buscar productos'),
        actions: [
          IconButton(
            tooltip: 'Actualizar catálogo',
            onPressed: _recargar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Nombre o categoría del producto',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        onPressed: _searchController.clear,
                        icon: const Icon(Icons.close),
                      ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<ProductoModel>>(
              future: _productosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'No se pudieron cargar los productos:\n${snapshot.error}',
                          textAlign: TextAlign.center,
                        ),
                        TextButton(
                          onPressed: _recargar,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }
                final productos = (snapshot.data ?? []).where((producto) {
                  final buscable =
                      '${producto.nombre} ${producto.categoria} ${producto.descripcion}'
                          .toLowerCase();
                  return buscable.contains(_query);
                }).toList();
                if (productos.isEmpty) {
                  return const Center(
                    child: Text('No se encontraron productos.'),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: productos.length,
                  itemBuilder: (context, index) =>
                      _productoCard(productos[index]),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomerBottomNavigation(selectedIndex: 1),
    );
  }

  Widget _productoCard(ProductoModel producto) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: producto.imagenUrl.isEmpty
            ? const CircleAvatar(child: Icon(Icons.fastfood))
            : CircleAvatar(
                backgroundImage: NetworkImage(producto.imagenUrl),
                onBackgroundImageError: (_, _) {},
              ),
        title: Text(producto.nombre),
        subtitle: Text(
          '${producto.categoria} · \$${producto.precio.toStringAsFixed(0)} COP',
        ),
        trailing: IconButton(
          tooltip: 'Agregar al carrito',
          onPressed: () {
            CartService.instance.add(producto);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${producto.nombre} agregado al carrito')),
            );
          },
          icon: const Icon(Icons.add_shopping_cart),
          color: AppColors.barraHome,
        ),
      ),
    );
  }
}
