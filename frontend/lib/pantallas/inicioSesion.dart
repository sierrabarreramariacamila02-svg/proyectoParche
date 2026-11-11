import 'package:elparchee/models/user_model.dart';
import 'package:elparchee/pantallas/recuperacioncuenta.dart';
import 'package:elparchee/pantallas/registro.dart';
import 'package:elparchee/services/role_navigation.dart';
import 'package:elparchee/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class Iniciosesion extends StatefulWidget {
  const Iniciosesion({super.key});

  @override
  State<Iniciosesion> createState() => _IniciosesionState();
}

class _IniciosesionState extends State<Iniciosesion> {
  static const _googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue:
        '1019899287750-nq15fegk865o24f27j6hns9appjs3rf2.apps.googleusercontent.com',
  );

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final UserService _userService = UserService();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? _googleWebClientId : null,
  );

  bool _cargando = false;

  Future<void> _guardarSesionYNavegar(Map<String, dynamic> respuesta) async {
    final String token = (respuesta['token'] ?? '').toString();
    final Map<String, dynamic> usuarioJson = Map<String, dynamic>.from(
      respuesta['usuario'] ?? <String, dynamic>{},
    );

    if (usuarioJson.isEmpty) {
      throw Exception('La respuesta del servidor no incluye la sesión activa.');
    }

    final UserModel usuario = UserModel.fromJson(usuarioJson);
    if (token.isEmpty) {
      throw Exception('El servidor no devolvió un token de sesión válido.');
    }

    final String rol = (usuarioJson['rol'] ?? 'usuario')
        .toString()
        .toLowerCase()
        .trim();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
    await prefs.setString('user_role', rol);
    await prefs.setString('user_rol', rol);
    await prefs.setString('user_name', usuario.nombre);
    await prefs.setString('user_email', usuario.email);

    if (!mounted) return;

    if (rol == 'pendiente') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tu cuenta está pendiente de aprobación por el administrador.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
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
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _mostrarMensaje('Ingresa tu email y contraseña.', color: Colors.orange);
      return;
    }

    setState(() => _cargando = true);

    try {
      final response = await _userService.loginUsuario(email, password);
      await _guardarSesionYNavegar(response);
    } catch (e) {
      if (!mounted) return;
      _mostrarMensaje(
        e.toString().replaceAll('Exception: ', ''),
        color: Colors.red,
      );
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  Future<void> _loginConGoogle() async {
    if (_cargando) return;

    setState(() => _cargando = true);

    try {
      final googleAccount = await _googleSignIn.signIn();
      if (googleAccount == null) {
        if (!mounted) return;
        _mostrarMensaje(
          'Inicio de sesión con Google cancelado.',
          color: Colors.orange,
        );
        return;
      }

      final googleAuth = await googleAccount.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw Exception(
          'No se pudo obtener el token de autenticación de Google.',
        );
      }

      final response = await _userService.autenticarConGoogleBackend(idToken);
      await _guardarSesionYNavegar(response);
    } catch (e) {
      if (!mounted) return;
      _mostrarMensaje(
        e.toString().replaceAll('Exception: ', ''),
        color: Colors.red,
      );
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  void _mostrarMensaje(String mensaje, {required Color color}) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje), backgroundColor: color));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                    const SizedBox(height: 20),
                    Transform.translate(
                      offset: const Offset(0, 20),
                      child: const Text(
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
                    ),
                    const SizedBox(height: 20),
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
                        child: _cargando
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
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
