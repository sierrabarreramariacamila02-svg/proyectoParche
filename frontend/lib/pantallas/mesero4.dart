import 'package:flutter/material.dart';

class MesasActivasScreen extends StatefulWidget {
  const MesasActivasScreen({Key? key}) : super(key: key);

  @override
  State<MesasActivasScreen> createState() => _MesasActivasScreenState();
}

class _MesasActivasScreenState extends State<MesasActivasScreen> {
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
          'Mesas y pedidos activos',
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
                _buildFilterButton('Todos', true),
                _buildFilterButton('Pendientes', false),
                _buildFilterButton('En cocina', false),
                _buildFilterButton('Listos', false),
              ],
            ),
          ),
          // Lista de pedidos activos
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildActiveOrderCard('Mesa #5', 'Andrés R.', '01:12', 'En cocina', '\$84.000', Colors.orange),
                _buildActiveOrderCard('Mesa #3', 'Valentina G.', '00:48', 'Pendiente', '\$46.000', Colors.amber),
                _buildActiveOrderCard('Mesa #7', 'Andrés R.', '00:25', 'En cocina', '\$36.000', Colors.orange),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFD35400) : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFFD35400),
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildActiveOrderCard(String mesa, String mesero, String tiempo, String estado, String total, Color colorEstado) {
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.table_restaurant, size: 20, color: Color(0xFF6B1D0F)),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(mesa, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(mesero, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colorEstado.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(estado, style: TextStyle(color: colorEstado, fontWeight: FontWeight.bold, fontSize: 11)),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(tiempo, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              Text(total, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFD35400)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () {},
                  child: const Text('Ver pedido', style: TextStyle(color: Color(0xFFD35400), fontSize: 13)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD35400),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () {},
                  child: const Text('Abrir mesa', style: TextStyle(color: Colors.white, fontSize: 13)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}