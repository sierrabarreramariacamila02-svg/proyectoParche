import 'package:elparchee/components/productos.dart';
import 'package:elparchee/pantallas/bienvenidos.dart';
import 'package:elparchee/pantallas/inicio.dart';
import 'package:elparchee/pantallas/inicioSesion.dart';
import 'package:elparchee/pantallas/verificacion.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// 1. Manejador de notificaciones en segundo plano
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Mensaje recibido en segundo plano: ${message.messageId}");
}

void main() async {
  // 2. Asegurar la inicialización y Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Registrar el manejador de segundo plano
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

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

  // 3. Configurar permisos y escucha de notificaciones
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

    // Escuchar mensajes en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('¡Notificación recibida en primer plano!');
      if (message.notification != null) {
        print('Título: ${message.notification?.title}');
        print('Cuerpo: ${message.notification?.body}');
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
      ), // ThemeData
      home: const Inicio(),
      routes: {
        '/login': (context) => const Iniciosesion(),
        '/verificacion': (context) => const Verificacion(),
        '/menu': (context) => const Productos(),
        '/bienvenidos': (context) => const Bienvenidos(),
        // Rutas añadidas para que coincidan con las opciones de tu DrawerContent:
        '/inicio': (context) => const Inicio(),
        '/platos': (context) =>
            const Productos(), // O cámbialo por su pantalla respectiva cuando la crees
        '/carrito': (context) => const Productos(),
        '/pedidos': (context) => const Productos(),
        '/domicilios': (context) => const Productos(),
        '/favoritos': (context) => const Productos(),
        '/promociones': (context) => const Productos(),
        '/perfil': (context) => const Productos(),
        '/administracion': (context) => const Productos(isAdmin: true),
      },
    ); // MaterialApp
  }
}