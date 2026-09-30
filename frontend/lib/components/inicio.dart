import 'package:flutter/material.dart';
import 'package:parche/components/inicioSesion.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';

class Inicio extends StatefulWidget {
  const Inicio({super.key});

  @override
  State<Inicio> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<Inicio> {
  late VideoPlayerController _videoController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // 1. Inicializar el video (desde assets)
    _videoController = VideoPlayerController.asset('assets/videos/fondo.mp4')
      ..initialize().then((_) {
        setState(() {}); // Actualiza la UI cuando el video esté cargado
      })
      ..setLooping(true) // Repetir en bucle
      ..setVolume(0.0) // Silenciar si es un video de fondo
      ..play(); // Iniciar reproducción

    // 2. Temporizador de 5 segundos para cambiar de pantalla
    _timer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Iniciosesion()),
        );
      }
    });
  }

  @override
  void dispose() {
    // Liberar recursos de memoria al salir de la pantalla
    _videoController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo de Video
          _videoController.value.isInitialized
              ? SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _videoController.value.size.width,
                      height: _videoController.value.size.height,
                      child: VideoPlayer(_videoController),
                    ),
                  ),
                )
              : Container(color: Colors.black), // Fondo mientas carga el video
          // Logo o elementos encima del video
          Center(
            child: Image.asset(
              'assets/images/logo-parche.png', // Reemplaza por tu logo
              width: 200,
            ),
          ),
        ],
      ),
    );
  }
}
