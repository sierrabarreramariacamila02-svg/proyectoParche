import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:elparchee/pantallas/inicioSesion.dart';

class Inicio extends StatefulWidget {
  const Inicio({super.key});

  @override
  State<Inicio> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<Inicio> {
  late final VideoPlayerController _videoController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _videoController = VideoPlayerController.asset('assets/videos/fondo.mp4')
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
        }
      })
      ..setLooping(true)
      ..setVolume(0.0)
      ..play();

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
    _videoController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
              : Container(color: Colors.black),
          Center(
            child: Image.asset(
              'assets/images/logo-parche.png',
              width: 200,
            ),
          ),
        ],
      ),
    );
  }
}
