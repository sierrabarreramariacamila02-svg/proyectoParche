import 'package:elparchee/components/productos.dart';
import 'package:elparchee/models/user_model.dart';
import 'package:elparchee/pages/admin_product_list_page.dart';
import 'package:elparchee/pantallas/recuperacioncuenta.dart';
import 'package:elparchee/pantallas/registro.dart';
import 'package:elparchee/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Iniciosesion extends StatefulWidget {
  const Iniciosesion({super.key});

  @override
  State<Iniciosesion> createState() => _IniciosesionState();
}

class _IniciosesionState extends State<Iniciosesion> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _cargando = false; // Declarada por si acaso faltaba en tu clase

  Future<void> _guardarSesionYNavegar(Map<String, dynamic> respuesta) async {
    final String token = (respuesta['token'] ?? '').toString();
    final Map<String, dynamic> usuarioJson = Map<String, dynamic>.from(
      respuesta['usuario'] ?? <String, dynamic>{},
    );
    final UserModel usuario = UserModel.fromJson(usuarioJson);

    final String rol = (usuarioJson['rol'] ?? 'usuario')
        .toString()
        .toLowerCase();

    // Guardar la sesión correctamente usando la variable 'respuesta' y el objeto 'usuario'
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
    await prefs.setString('user_role', rol);
    await prefs.setString('user_name', usuario.nombre);
    await prefs.setString('user_email', usuario.email);

    if (!mounted) return;

    // Validación si la cuenta se encuentra pendiente de aprobación
    if (rol == 'pendiente') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tu cuenta está pendiente de aprobación por el administrador.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return; // Detiene la navegación si no está aprobado
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('¡Bienvenido, ${usuario.nombre}!')));

    Widget pantallaDestino;

    switch (rol) {
      case 'admin':
      case 'administrador':
        pantallaDestino =
            const AdminProductListPage(); // Panel de administración
        break;
      case 'cocina':
        // pantallaDestino = const CocinaPage();
        pantallaDestino = const Productos(); // Reemplazar cuando crees la vista
        break;
      case 'mesero':
        // pantallaDestino = const MeseroPage();
        pantallaDestino = const Productos(); // Reemplazar cuando crees la vista
        break;
      case 'domicilio':
      case 'domiciliario':
        // pantallaDestino = const DomicilioPage();
        pantallaDestino = const Productos(); // Reemplazar cuando crees la vista
        break;
      case 'usuario':
      default:
        pantallaDestino = const Productos(); // Vista normal para el cliente
        break;
    }

    if (!mounted) return;

    // Redirección dinámica según la pantallaDestino calculada
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => pantallaDestino),
    );
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa tu email y contraseña')),
      );
      return;
    }

    setState(() => _cargando = true);

    try {
      final respuesta = await UserService().loginUsuario(email, password);
      await _guardarSesionYNavegar(respuesta);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
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
                    const SizedBox(height: 4),
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
                      elevation: 4,
                      borderRadius: const BorderRadius.all(Radius.circular(30)),
                      child: _Input(
                        hint: 'Email/Usuario',
                        icon: Icons.email_outlined,
                        controller: _emailController,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Material(
                      elevation: 4,
                      borderRadius: const BorderRadius.all(Radius.circular(30)),
                      child: _Input(
                        hint: 'Contraseña',
                        icon: Icons.lock_outline,
                        pass: true,
                        controller: _passwordController,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RecuperacionCuenta(),
                            ),
                          );
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
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _cargando ? null : _login,
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
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Al continuar, aceptas nuestros Terminos y condiciones y Politicas de privacidad.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
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
  final TextEditingController controller;

  const _Input({
    required this.hint,
    required this.icon,
    required this.controller,
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
        controller: controller,
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
    );
  }
}
