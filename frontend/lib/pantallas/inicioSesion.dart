import 'package:elparchee/models/user_model.dart';
import 'package:elparchee/pantallas/recuperacioncuenta.dart';
import 'package:elparchee/pantallas/registro.dart';
import 'package:elparchee/services/role_navigation.dart';
import 'package:elparchee/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';

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

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => pantallaParaRol(rol)),
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

  // ==========================================
  // NUEVO: Función para iniciar sesión con Google
  // ==========================================
  Future<void> _loginConGoogle() async {
    setState(() => _cargando = true);

    try {
      await GoogleSignIn().signOut();
      // 1. Abrir la ventana emergente de Google
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // El usuario canceló el inicio de sesión
        if (mounted) setState(() => _cargando = false);
        return;
      }

      final String email = googleUser.email;
      final String name = googleUser.displayName ?? 'Usuario';

      // 2. Enviar los datos al nuevo endpoint de tu backend
      // Recuerda cambiar la IP según tu entorno (10.0.2.2 para emulador Android o tu IP local)
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'name': name}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> respuesta = jsonDecode(response.body);

        // 3. Reutilizamos tu método existente para guardar sesión y navegar según el rol
        await _guardarSesionYNavegar(respuesta);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Error al autenticar con Google');
      }
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
                    const SizedBox(height: 25),
                    Transform.translate(offset: const Offset(0, 20)),
                    const Text(
                      '¡BIENVENIDO!',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFD35400),
                        shadows: [
                          Shadow(
                            offset: Offset(2, 2),
                            blurRadius: 15,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),
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
                      elevation: 5,
                      borderRadius: const BorderRadius.all(Radius.circular(30)),
                      child: _Input(
                        hint: 'Correo',
                        icon: Icons.email_outlined,
                        controller: _emailController,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Material(
                      elevation: 5,
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: _cargando ? null : _loginConGoogle,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black38,
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/google.png',
                                  height: 30,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Google',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
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
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 16.0,
          ),
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
