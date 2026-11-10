import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  @override
  void initState() {
    super.initState();
    
    // Opcional: Escuchar por si llega una notificación push en primer plano 
    // y asegurarnos de que quede registrada o manejada visualmente.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        // La notificación ya se guardó en Supabase desde el origen (Admin),
        // por lo que el StreamBuilder la detectará automáticamente en tiempo real.
        print("Notificación en primer plano recibida: ${message.notification?.title}");
      }
    });
  }

  // Marcar todas como leídas actualizando la base de datos de Supabase
  Future<void> _marcarTodasComoLeidas() async {
    try {
      final supabase = Supabase.instance.client;
      await supabase
          .from('notificaciones')
          .update({'leida': true})
          .eq('leida', false);
    } catch (e) {
      print('Error al marcar todas como leídas: $e');
    }
  }

  // Marcar una sola notificación como leída al tocarla
  Future<void> _marcarComoLeida(String id) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase
          .from('notificaciones')
          .update({'leida': true})
          .eq('id', id);
    } catch (e) {
      print('Error al marcar notificación como leída: $e');
    }
  }

  // Helper para asignar iconos según el tipo o contenido
  IconData _obtenerIcono(String titulo, String cuerpo) {
    final texto = '$titulo $cuerpo'.toLowerCase();
    if (texto.contains('pedido') || texto.contains('camino')) return Icons.delivery_dining;
    if (texto.contains('descuento') || texto.contains('promo') || texto.contains('producto')) return Icons.local_offer;
    if (texto.contains('pago')) return Icons.payment;
    if (texto.contains('bienvenido')) return Icons.star_outline;
    return Icons.notifications;
  }

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

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
      // 🚀 PASO 2 IMPLEMENTADO: StreamBuilder conectado a Supabase en tiempo real
      body: StreamBuilder<List>(
        stream: supabase
            .from('notificaciones')
            .stream(primaryKey: ['id'])
            .order('fecha', ascending: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: rojo),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No tienes notificaciones por ahora',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          final listaNotificaciones = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: listaNotificaciones.length,
            itemBuilder: (context, index) {
              final item = listaNotificaciones[index];
              final String id = item['id'].toString();
              final String titulo = item['titulo'] ?? '';
              final String mensaje = item['cuerpo'] ?? '';
              final bool esLeida = item['leida'] ?? false;
              final IconData iconoApp = _obtenerIcono(titulo, mensaje);

              return GestureDetector(
                onTap: () => _marcarComoLeida(id),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: esLeida ? Colors.transparent : naranja,
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
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: esLeida ? Colors.grey.shade200 : naranja,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          iconoApp,
                          color: esLeida ? Colors.grey : rojo,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    titulo,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: esLeida ? Colors.black87 : rojo,
                                    ),
                                  ),
                                ),
                                const Text(
                                  'Reciente',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              mensaje,
                              style: TextStyle(
                                fontSize: 12,
                                color: esLeida
                                    ? Colors.grey.shade700
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
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
          );
        },
      ),
    );
  }
}