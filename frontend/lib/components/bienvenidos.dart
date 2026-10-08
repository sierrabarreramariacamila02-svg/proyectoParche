import 'package:elparchee/components/productos.dart';
import 'package:flutter/material.dart';

class Bienvenidos extends StatefulWidget {
  const Bienvenidos({super.key});

  @override
  State<Bienvenidos> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<Bienvenidos> {
 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6EE),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Logo centrado con resplandor
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD35400),
                        blurRadius: 15,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/logo-parche.png',
                    height: 85,
                  ),
                ),
              ),
              const SizedBox(height: 25),
              // Título principal
              const Text(
                '¡YA ERES PARTE\nDEL PARCHE!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              // Subtítulo
              const Text(
                'Descubre los mejores combos y\npromociones para compartir hoy.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              // Ilustración central
              Expanded(
                child: Image.asset(
                  'assets/images/imagen-familia.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 15),
            
              const SizedBox(height: 25),
              // Botón "EXPLORAR EL PARCHE."
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navegar al Home / Menú principal
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Productos() ,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE59866),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'EXPLORAR EL PARCHE.',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
