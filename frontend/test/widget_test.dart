// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:elparchee/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD

=======
>>>>>>> 3da53de1750715ee79dc66c1d9585220dbbfcba7
=======
>>>>>>> paola
=======
<<<<<<< Updated upstream
>>>>>>> paola
import 'package:elparchee/main.dart';
=======
>>>>>>> Stashed changes

void main() {
  testWidgets('Main app builds', (WidgetTester tester) async {
    await tester.pumpWidget(const MainApp());

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
