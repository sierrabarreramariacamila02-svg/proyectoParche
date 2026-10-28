import 'package:flutter/material.dart';

class TomarPedidoScreen extends StatefulWidget {
  const TomarPedidoScreen({Key? key}) : super(key: key);

  @override
  State<TomarPedidoScreen> createState() => _TomarPedidoScreenState();
}

class _TomarPedidoScreenState extends State<TomarPedidoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B1D0F),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {},
        ),
        title: const Text(
          'Tomar pedido',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Cabecera de Mesa
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFD35400),
            child: Row(
              children: const [
                Icon(Icons.table_restaurant, color: Colors.white),
                SizedBox(width: 8),
                Text('Mesa #5', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(width: 16),
                Text('2 personas', style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          // Lista de productos
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildProductItem('Hamburguesa clásica x2', '\$26.000', '2'),
                const Divider(),
                _buildProductItem('Perro caliente x1', '\$28.000', '1'),
                const Divider(),
                _buildProductItem('Salchipapa x1', '\$30.000', '1'),
              ],
            ),
          ),
          // Total y Botones de acción
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFF5EBE6),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('\$84.000', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD35400),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.soup_kitchen, color: Colors.white),
                    label: const Text('Enviar a cocina', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFD35400)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    onPressed: () {},
                    child: const Text('Actualizar / Agregar +', style: TextStyle(color: Color(0xFFD35400), fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(String title, String price, String count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 4),
              Text(price, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
          Row(
            children: [
              _qtyButton('-', () {}),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(count, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              _qtyButton('+', () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtyButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: 28,
      height: 28,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: Colors.orange.shade100,
          foregroundColor: const Color(0xFFD35400),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}