import 'package:elparchee/pantallas/registro.dart';
import 'package:flutter/material.dart';
<<<<<<< Updated upstream
import 'package:elparchee/pantallas/registro.dart';
=======
>>>>>>> Stashed changes

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

        decoration: BoxDecoration(
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
                    Text(
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
                    const SizedBox(height: 20),
                    Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(30),
                      child: const _Input(
                        hint: 'Email/Usuario',
                        icon: Icons.email_outlined,
                      ),
                    ),

                    SizedBox(height: 14),
                    Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(30),
                      child: const _Input(
                        hint: 'Contraseña',
                        icon: Icons.lock_outline,
                        pass: true,
                      ),
                    ),

                    SizedBox(height: 22),
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
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(color: Colors.black38, thickness: 1),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'O continuar con',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const Expanded(
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
                            height: 26,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const _Social(
                          child: Icon(
                            Icons.email,
                            color: Color(0xFF1877F2),
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 25),

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
  const _Input({required this.hint, required this.icon, this.pass = false});

  @override
  Widget build(BuildContext context) => Container(
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
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
      ),
    ),
  );
}

class _Social extends StatelessWidget {
  final Widget child;
  const _Social({required this.child});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8A35E), width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Center(child: child),
    ),
  );
}
