import 'package:elparchee/components/productos.dart';
import 'package:elparchee/pantallas/cocina_pedidos.dart';
import 'package:elparchee/pantallas/domicilio.dart';
import 'package:elparchee/pantallas/mesero1.dart';
import 'package:flutter/material.dart';

Widget pantallaParaRol(String rol) {
  switch (rol.toLowerCase().trim()) {
    case 'admin':
    case 'administrador':
      return const Productos(isAdmin: true);
    case 'cocina':
    case 'cocinero':
      return const Cocina();
    case 'mesero':
      return const GestionMesas();
    case 'domicilio':
    case 'domiciliario':
      return const DomicilioPantalla();
    default:
      return const Productos();
  }
}
