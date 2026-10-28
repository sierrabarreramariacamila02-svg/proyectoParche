import 'package:flutter/material.dart';

class PedidosEnCocinaScreen extends StatelessWidget {
  const PedidosEnCocinaScreen({Key? key}) : super(key: key);

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
          'Pedidos en cocina',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filtros superiores
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFilterChip('Pendientes', '3', true),
                _buildFilterChip('En preparación', '2', false),
                _buildFilterChip('Listos', '1', false),
              ],
            ),
          ),
          // Lista de pedidos
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildOrderCard(
                  'Pedido #025',
                  'Mesa #5  •  Andrés R.',
                  '10:35 a. m.',
                  'Pendiente',
                  Colors.amber.shade700,
                  Colors.amber.shade100,
                  ['• Hamburguesa clásica x2', '• Perro caliente x1', '• Salchipapa x1'],
                ),
                _buildOrderCard(
                  'Pedido #026',
                  'Mesa #3  •  Valentina G.',
                  '10:42 a. m.',
                  'En preparación',
                  const Color(0xFFD35400),
                  Colors.orange.shade100,
                  ['• Hamburguesa clásica x1', '• Papas a la francesa x1'],
                ),
                _buildOrderCard(
                  'Pedido #027',
                  'Mesa #7  •  Andrés R.',
                  '10:50 a. m.',
                  'Pendiente',
                  Colors.amber.shade700,
                  Colors.amber.shade100,
                  ['• Gaseosa 400 ml x1', '• Salchipapa x1'],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String count, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFD35400) : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFFD35400),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 6),
          CircleAvatar(
            radius: 10,
            backgroundColor: isSelected ? Colors.white : const Color(0xFFD35400),
            child: Text(
              count,
              style: TextStyle(
                color: isSelected ? const Color(0xFFD35400) : Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(String title, String subtitle, String time, String status, Color statusColor, Color statusBg, List<String> items) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4, spreadRadius: 1),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  Text(time, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ],
          ),
          const Divider(height: 16),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Text(item, style: const TextStyle(fontSize: 13, color: Colors.black87)),
              )),
        ],
      ),
    );
  }
}