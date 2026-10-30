import 'package:flutter/material.dart';

class EnPreparacionScreen extends StatelessWidget {
  const EnPreparacionScreen({Key? key}) : super(key: key);

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
          'En preparación',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPrepCard('Pedido #025', '10:35 a. m.', [
            {'name': 'Hamburguesa clásica', 'progress': '2/2', 'value': 1.0},
            {'name': 'Perro caliente', 'progress': '1/1', 'value': 1.0},
            {'name': 'Salchipapa', 'progress': '0/1', 'value': 0.0},
          ]),
          const SizedBox(height: 12),
          _buildPrepCard('Pedido #026', '10:42 a. m.', [
            {'name': 'Hamburguesa clásica', 'progress': '1/1', 'value': 1.0},
            {'name': 'Papas a la francesa', 'progress': '0/1', 'value': 0.0},
          ]),
        ],
      ),
    );
  }

  Widget _buildPrepCard(String orderTitle, String time, List<Map<String, dynamic>> items) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.soup_kitchen, color: Color(0xFFD35400), size: 20),
                  const SizedBox(width: 8),
                  Text(orderTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
              Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('En preparación', style: TextStyle(color: Color(0xFFD35400), fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const Divider(height: 16),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item['name'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                        Text(item['progress'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: item['value'],
                      backgroundColor: Colors.grey.shade200,
                      color: const Color(0xFFD35400),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}