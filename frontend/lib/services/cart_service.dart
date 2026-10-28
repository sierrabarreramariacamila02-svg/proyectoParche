import 'package:flutter/foundation.dart';

import '../models/producto_model.dart';

class CartService extends ChangeNotifier {
  CartService._();

  static final CartService instance = CartService._();

  // Corregido: _CartLine cambiado a CartLine
  final Map<String, CartLine> _items = {};

  List<CartLine> get items => List.unmodifiable(_items.values);

  int get itemCount =>
      _items.values.fold(0, (total, item) => total + item.quantity);

  double get subtotal => _items.values.fold(
    0.0, // Cambiado a 0.0 para que coincida con el tipo double
    (total, item) => total + item.product.precio * item.quantity,
  );

  bool get isEmpty => _items.isEmpty;

  void add(ProductoModel product) {
    final current = _items[product.id];
    if (current == null) {
      _items[product.id] = CartLine(product: product, quantity: 1);
    } else {
      current.quantity++;
    }
    notifyListeners();
  }

  void setQuantity(String productId, int quantity) {
    final item = _items[productId];
    if (item == null) return;
    if (quantity <= 0) {
      _items.remove(productId);
    } else {
      item.quantity = quantity;
    }
    notifyListeners();
  }

  void remove(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  List<Map<String, dynamic>> toOrderItems() => _items.values
      .map(
        (item) => {
          'producto_id': item.product.id,
          'cantidad': item.quantity,
        },
      )
      .toList();

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

class CartLine {
  final ProductoModel product;
  int quantity;

  CartLine({required this.product, required this.quantity});
}