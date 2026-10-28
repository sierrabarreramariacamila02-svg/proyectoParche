import 'package:flutter/material.dart';

class PedidoEnviadoScreen extends StatefulWidget {
  const PedidoEnviadoScreen({Key? key}) : super(key: key);

  @override
  State<PedidoEnviadoScreen> createState() => _PedidoEnviadoScreenState();
}

class _PedidoEnviadoScreenState extends State<PedidoEnviadoScreen> {
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
          'Pedido enviado',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono de check principal
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD35400), width: 3),
              ),
              child: const Icon(
                Icons.check,
                size: 64,
                color: Color(0xFFD35400),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '¡Pedido enviado a cocina!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'La mesa #5 ya está registrada.\nPuedes seguir atendiendo en otra mesa.',
              style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            // Botones inferiores
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD35400),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                onPressed: () {},
                child: const Text('Ver detalle del pedido', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFD35400)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                onPressed: () {},
                child: const Text('Volver a mesas', style: TextStyle(color: Color(0xFFD35400), fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}