import 'package:elparchee/components/productos.dart';
import 'package:elparchee/pantallas/bienvenidos.dart';
import 'package:elparchee/pantallas/inicio.dart';
import 'package:elparchee/pantallas/inicioSesion.dart';
import 'package:elparchee/pantallas/verificacion.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
<<<<<<< HEAD
import 'firebase_options.dart'; // <-- 1. Importa el archivo de opciones generado por Firebase
=======
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // 🚀 IMPORTACIÓN DE SUPABASE
>>>>>>> 48bdf18621d817100a66b4507635d1a4aff118e9

// 1. Definir el canal de notificaciones locales (Debe coincidir con el AndroidManifest)
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'Notificaciones Importantes',
  description: 'Este canal se usa para alertas de pedidos y promociones.',
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// 2. Manejador de notificaciones en segundo plano
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Mensaje recibido en segundo plano: ${message.messageId}");
}

void main() async {
<<<<<<< HEAD
  // 2. Asegurar la inicialización y Firebase con las opciones de la plataforma
=======
  // 3. Asegurar la inicialización y Firebase
>>>>>>> 48bdf18621d817100a66b4507635d1a4aff118e9
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions
        .currentPlatform, // <-- 2. Añade esta línea obligatoria para la Web
  );

  // 🚀 INICIALIZAR SUPABASE ANTES DE CORRER LA APLICACIÓN
  await Supabase.initialize(
    url: 'TU_SUPABASE_URL', // Reemplaza con tu URL de Supabase
    anonKey: 'TU_SUPABASE_ANON_KEY', // Reemplaza con tu Anon Key de Supabase
  );

  // Registrar el manejador de segundo plano
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 4. Inicializar el canal de notificaciones locales en Android
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    _setupNotifications();
  }

  // 5. Configurar permisos, suscripción a temas y escucha de notificaciones
  void _setupNotifications() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('Estado de permisos: ${settings.authorizationStatus}');

    // Obtener el Token FCM del dispositivo
    String? token = await messaging.getToken();
    print("FCM Token: $token");

    // 🚀 NUEVO: Suscribir automáticamente al usuario al tema de promociones
    try {
      await messaging.subscribeToTopic('promociones');
      print("¡Suscrito exitosamente al tema 'promociones'!");
    } catch (e) {
      print("Error al suscribirse al tema de promociones: $e");
    }

    // Escuchar mensajes en primer plano y mostrarlos visualmente
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('¡Notificación recibida en primer plano!');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: '@mipmap/ic_launcher', // Icono de la app
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'El parche',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8C0E0E)),
      ),
      home: const Inicio(),
      routes: {
        '/login': (context) => const Iniciosesion(),
        '/verificacion': (context) => const Verificacion(),
        '/menu': (context) => const Productos(),
        '/bienvenidos': (context) => const Bienvenidos(),
        '/inicio': (context) => const Inicio(),
        '/platos': (context) => const Productos(),
        '/carrito': (context) => const Productos(),
        '/pedidos': (context) => const Productos(),
        '/domicilios': (context) => const Productos(),
        '/favoritos': (context) => const Productos(),
        '/promociones': (context) => const Productos(),
        '/perfil': (context) => const Productos(),
        '/administracion': (context) => const Productos(isAdmin: true),
      },
    );
  }
}
