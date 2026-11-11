import 'package:flutter/material.dart';
import '../models/producto_model.dart';

class Mensaje {
  final String texto;
  final bool esUsuario;
  final List<ProductoModel> productos;

  const Mensaje({
    required this.texto,
    required this.esUsuario,
    this.productos = const [],
  });
}

class ChatBurbuja extends StatelessWidget {
  final Mensaje mensaje;
  final ValueChanged<ProductoModel>? onAgregarProducto;

  const ChatBurbuja({super.key, required this.mensaje, this.onAgregarProducto});

  @override
  Widget build(BuildContext context) {
    final esUsuario = mensaje.esUsuario;

    return Align(
      alignment: esUsuario ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          // Color naranja para el usuario y un tono gris/crema suave para la IA
          color: esUsuario ? const Color(0xFFE59866) : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(esUsuario ? 16 : 0),
            bottomRight: Radius.circular(esUsuario ? 0 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mensaje.texto,
              style: TextStyle(
                color: esUsuario ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
            if (!esUsuario)
              ...mensaje.productos.map(
                (producto) => Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onAgregarProducto == null
                          ? null
                          : () => onAgregarProducto!(producto),
                      icon: const Icon(Icons.add_shopping_cart, size: 18),
                      label: Text(
                        'Agregar ${producto.nombre} · \$${producto.precio.toStringAsFixed(0)}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF8A1C14),
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
