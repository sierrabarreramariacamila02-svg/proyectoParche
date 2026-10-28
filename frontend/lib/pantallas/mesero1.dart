import 'package:flutter/material.dart';

class GestionMesas extends StatefulWidget {
  const GestionMesas({Key? key}) : super(key: key);

  @override
  State<GestionMesas> createState() => _GestionMesasScreenState();
}

class _GestionMesasScreenState extends State<GestionMesas> {
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
          'Gestión de mesas',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: const Color(0xFFD35400),
              child: const Icon(Icons.restaurant, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Resumen superior
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusChip('Disponibles', '6', Colors.green.shade100, Colors.green.shade800),
                _buildStatusChip('Ocupadas', '3', Colors.orange.shade100, Colors.orange.shade800),
                _buildStatusChip('Por limpiar', '1', Colors.grey.shade300, Colors.grey.shade800),
              ],
            ),
            const SizedBox(height: 16),
            // Cuadrícula de mesas
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  _buildMesaCard('Mesa 1', 'Disponible', Colors.green, '4', '-'),
                  _buildMesaCard('Mesa 2', 'Ocupada', Colors.orange, '3', '00:45'),
                  _buildMesaCard('Mesa 3', 'Disponible', Colors.green, '2', '-'),
                  _buildMesaCard('Mesa 4', 'Por limpiar', Colors.grey, '0', '-'),
                  _buildMesaCard('Mesa 5', 'Ocupada', Colors.orange, '5', '01:20'),
                  _buildMesaCard('Mesa 6', 'Disponible', Colors.green, '4', '-'),
                ],
              ),
            ),
            // Botón inferior
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD35400),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: () {},
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Nueva orden',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, String count, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 4, backgroundColor: textColor),
          const SizedBox(width: 6),
          Text('$label\n$count', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildMesaCard(String mesa, String estado, Color colorEstado, String personas, String tiempo) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4, spreadRadius: 1),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(mesa, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colorEstado.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(estado, style: TextStyle(color: colorEstado, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [const Icon(Icons.person, size: 14, color: Colors.grey), const SizedBox(width: 4), Text(personas, style: const TextStyle(fontSize: 12, color: Colors.grey))]),
              Row(children: [const Icon(Icons.access_time, size: 14, color: Colors.grey), const SizedBox(width: 4), Text(tiempo, style: const TextStyle(fontSize: 12, color: Colors.grey))]),
            ],
          ),
        ],
      ),
    );
  }
}