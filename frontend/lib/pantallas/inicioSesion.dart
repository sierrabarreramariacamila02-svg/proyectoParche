<<<<<<< HEAD
import 'package:elparchee/pantallas/recuperacioncuenta.dart';
import 'package:elparchee/pantallas/registro.dart';
import 'package:flutter/material.dart';
=======
﻿import 'package:flutter/material.dart';


import 'package:elparchee/pantallas/registro.dart';
>>>>>>> 16cdaf6631759378ad4d70b2ced589019b4d0f44

class Iniciosesion extends StatefulWidget {
  const Iniciosesion({super.key});

  @override
  State<Iniciosesion> createState() => _IniciosesionState();
}

class _IniciosesionState extends State<Iniciosesion> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
<<<<<<< HEAD
        decoration: BoxDecoration(
=======
        decoration: const BoxDecoration(
>>>>>>> 16cdaf6631759378ad4d70b2ced589019b4d0f44
          image: DecorationImage(
            image: AssetImage('assets/images/background-fondo.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 180,
                      child: OverflowBox(
                        maxHeight: 700,
                        child: Image.asset(
                          'assets/images/logo-parche.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Transform.translate(offset: const Offset(0, -25)),
                    const Text(
                      '¡BIENVENIDO!',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFD35400),
                        shadows: [
                          Shadow(
                            offset: Offset(2, 2),
                            blurRadius: 3,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                    ),
<<<<<<< HEAD
                    const SizedBox(height: 4),
                    
                    // NUEVO: Subtítulo agregado
                    const Text(
                      'Inicia sesion para continuar',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    Material(
=======
                    const SizedBox(height: 20),
                    const Material(
>>>>>>> 16cdaf6631759378ad4d70b2ced589019b4d0f44
                      elevation: 4,
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                      child: _Input(
                        hint: 'Email/Usuario',
                        icon: Icons.email_outlined,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Material(
                      elevation: 4,
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                      child: _Input(
                        hint: 'Contraseña',
                        icon: Icons.lock_outline,
                        pass: true,
                      ),
                    ),
<<<<<<< HEAD

                    const SizedBox(height: 6),

                    // NUEVO "¿Olvidaste tu Contraseña?" navegable alineado a la derecha
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                                Navigator.push(context, 
                                MaterialPageRoute(builder: (context) => const RecuperacionCuenta()));
                          },
                        child: const Text(
                          '¿Olvidaste tu Contraseña?',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 18),
=======
                    const SizedBox(height: 22),
>>>>>>> 16cdaf6631759378ad4d70b2ced589019b4d0f44
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE8A35E),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'Iniciar sesión',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Row(
                      children: [
                        Expanded(
                          child: Divider(color: Colors.black38, thickness: 1),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'O continuar con',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(color: Colors.black38, thickness: 1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _Social(
                          child: Image.asset(
                            'assets/images/google.png',
                            height: 30,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '¿No tienes cuenta? ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'registrate aqui',
                            style: TextStyle(
                              color: Color(0xFFD35400),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
<<<<<<< HEAD
                    ),
                    
                    const SizedBox(height: 15),

                    // NUEVO: Texto de Términos y condiciones inferior
                    const Text(
                      'Al continuar, aceptas nuestros Terminos y condiciones y Politicas de privacidad.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
=======
>>>>>>> 16cdaf6631759378ad4d70b2ced589019b4d0f44
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Input extends StatelessWidget {
  final String hint;
  final IconData icon;
  final bool pass;

  const _Input({
    required this.hint,
    required this.icon,
    this.pass = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7EBD9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8A35E), width: 1.5),
      ),
      child: TextField(
        obscureText: pass,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: const Color(0xFFB94E0C)),
        ),
      ),
    );
  }
}

class _Social extends StatelessWidget {
  final Widget child;

  const _Social({required this.child});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Center(child: child),
      ),
<<<<<<< HEAD
      child: Center(child: child),
    ),
  );
}
=======
    );
  }
}
>>>>>>> 16cdaf6631759378ad4d70b2ced589019b4d0f44
