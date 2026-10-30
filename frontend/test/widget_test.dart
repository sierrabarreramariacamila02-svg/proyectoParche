import 'package:elparchee/main.dart';
import 'package:elparchee/models/producto_model.dart';
import 'package:elparchee/services/cart_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Main app builds', (WidgetTester tester) async {
    await tester.pumpWidget(const MainApp());

    expect(find.byType(MaterialApp), findsOneWidget);
  });

  test('Cart adds the requested quantity and updates subtotal', () {
    final cart = CartService.instance;
    cart.clear();
    final product = ProductoModel(
      id: 'test-product',
      nombre: 'Producto de prueba',
      descripcion: '',
      precio: 2500,
      categoria: 'Otros',
      imagenUrl: '',
    );

    cart.add(product, quantity: 3);
    cart.add(product, quantity: 2);

    expect(cart.itemCount, 5);
    expect(cart.subtotal, 12500);
    cart.clear();
  });
}
