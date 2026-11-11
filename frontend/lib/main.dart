import 'package:elparchee/components/productos.dart';
import 'package:elparchee/pantallas/bienvenidos.dart';
import 'package:elparchee/pantallas/inicio.dart';
import 'package:elparchee/pantallas/inicioSesion.dart';
import 'package:elparchee/pantallas/verificacion.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'firebase_options.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'Notificaciones Importantes',
  description: 'Este canal se usa para alertas de pedidos y promociones.',
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Mensaje recibido en segundo plano: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inicializar Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 2. Inicializar Supabase de forma segura
  // (Asegúrate de reemplazar los textos temporales con tus credenciales reales si no usas variables de entorno)
  const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://fmfneevycopvgdslzyzp.supabase.co',
  );
  const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_W79h4DAnAifwbWLferkKTA_1eCHO16R',
  );

  if (supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty &&
      supabaseUrl != 'TU_URL_DE_SUPABASE') {
    final parsedSupabaseUrl = Uri.parse(supabaseUrl.trim());
    final pathSegments = parsedSupabaseUrl.pathSegments
        .where((segment) => segment.isNotEmpty)
        .toList();
    if (pathSegments.length >= 2 &&
        pathSegments[pathSegments.length - 2] == 'rest' &&
        pathSegments.last == 'v1') {
      pathSegments.removeRange(pathSegments.length - 2, pathSegments.length);
    }
    final supabaseBaseUrl = parsedSupabaseUrl
        .replace(pathSegments: pathSegments, query: null, fragment: null)
        .toString()
        .replaceFirst(RegExp(r'/+$'), '');
    debugPrint('Supabase project host: ${Uri.parse(supabaseBaseUrl).host}');
    await Supabase.initialize(
      url: supabaseBaseUrl,
      publishableKey: supabaseAnonKey,
    );
  } else {
    await Supabase.initialize(
      url: 'https://fmfneevycopvgdslzyzp.supabase.co', // <-- SIN /rest/v1/
      publishableKey:
          'sb_publishable_W79h4DAnAifwbWLferkKTA_1eCHO16R', // <-- anonKey con K mayúscula
    );
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
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

  // Configurar permisos, suscripción a temas y escucha de notificaciones
  void _setupNotifications() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('Estado de permisos: ${settings.authorizationStatus}');

    // Obtener el Token FCM del dispositivo
    String? token = await messaging.getToken();
    debugPrint("FCM Token: $token");

    // Suscribir automáticamente al usuario al tema de promociones
    try {
      await messaging.subscribeToTopic('promociones');
      debugPrint("¡Suscrito exitosamente al tema 'promociones'!");
    } catch (e) {
      debugPrint("Error al suscribirse al tema de promociones: $e");
    }

    // Escuchar mensajes en primer plano y mostrarlos visualmente
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('¡Notificación recibida en primer plano!');
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
