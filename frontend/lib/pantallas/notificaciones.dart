import 'package:flutter/material.dart';
import 'package:elparchee/app_colors.dart';

class Notificaciones extends StatefulWidget {
  const Notificaciones({super.key});

  @override
  State<Notificaciones> createState() => _NotificacionesState();
}

class _NotificacionesState extends State<Notificaciones> {
  static const Color rojo = AppColors.barraHome;
  static const Color naranja = AppColors.buttonOrange;
  static const Color crema = Color(0xFFFAF3E0);

  // Lista simulada de notificaciones
  final List<Map<String, dynamic>> _listaNotificaciones = [
    {
      'id': '1',
      'titulo': '¡Tu pedido va en camino!',
      'mensaje': 'El repartidor ya lleva tu Combo de Perros Calientes. ¡Alístate!',
      'hora': 'Hace 5 min',
      'tipo': 'pedido',
      'leido': false,
      'icono': Icons.delivery_dining,
    },
    {
      'id': '2',
      'titulo': '🔥 ¡20% de Descuento Hoy!',
      'mensaje': 'Disfruta de nuestra promoción en combos familiares hasta las 8:00 PM.',
      'hora': 'Hace 2 horas',
      'tipo': 'promo',
      'leido': false,
      'icono': Icons.local_offer,
    },
    {
      'id': '3',
      'titulo': 'Pedido Entregado #1230',
      'mensaje': 'Gracias por comprar en El Parche. ¡Esperamos que lo disfrutes!',
      'hora': 'Ayer',
      'tipo': 'pedido',
      'leido': true,
      'icono': Icons.check_circle_outline,
    },
    {
      'id': '4',
      'titulo': 'Bienvenido a El Parchee 🍔',
      'mensaje': 'Explora nuestro menú y realiza tu primer pedido con envíos rápidos.',
      'hora': 'Hace 3 días',
      'tipo': 'sistema',
      'leido': true,
      'icono': Icons.star_outline,
    },
  ];

  void _marcarTodasComoLeidas() {
    setState(() {
      for (var item in _listaNotificaciones) {
        item['leido'] = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: crema,
      appBar: AppBar(
        backgroundColor: rojo,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notificaciones',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Marcar todas como leídas',
            icon: const Icon(Icons.done_all, color: Colors.white),
            onPressed: _marcarTodasComoLeidas,
          ),
        ],
      ),
      body: _listaNotificaciones.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'No tienes notificaciones por ahora',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _listaNotificaciones.length,
              itemBuilder: (context, index) {
                final item = _listaNotificaciones[index];
                final bool esLeida = item['leido'] as bool;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      item['leido'] = true;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: esLeida ? Colors.white.withOpacity(0.85) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: esLeida ? Colors.transparent : naranja.withOpacity(0.5),
                        width: 1.5,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icono decorativo de la notificación
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: esLeida ? Colors.grey.shade200 : naranja.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item['icono'] as IconData,
                            color: esLeida ? Colors.grey : rojo,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Contenido (Título, mensaje y hora)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item['titulo'] as String,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: esLeida ? Colors.black87 : rojo,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    item['hora'] as String,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['mensaje'] as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: esLeida ? Colors.grey.shade700 : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Indicador de "no leído"
                        if (!esLeida) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(top: 6),
                            decoration: const BoxDecoration(
                              color: naranja,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}