import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:elparchee/models/user_model.dart';
import 'package:elparchee/services/user_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nombre = TextEditingController();
  final _telefono = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _isLoading = false;
  bool _verPassword = false;

  // Las 3 reglas de seguridad de la contraseña
  bool get _tiene8 => _password.text.length >= 8;
  bool get _tieneMayuscula => RegExp(r'[A-Z]').hasMatch(_password.text);
  bool get _tieneNumero => RegExp(r'\d').hasMatch(_password.text);

  @override
  void dispose() {
    for (final c in [_nombre, _telefono, _email, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  void _aviso(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  Future<void> _registrar() async {
    final nombre = _nombre.text.trim();
    final telefono = _telefono.text.trim();
    final email = _email.text.trim();
    final password = _password.text;

    if (nombre.isEmpty ||
        telefono.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        _confirm.text.isEmpty) {
      return _aviso('Por favor llena todos los campos');
    }
    if (!RegExp(r'^\d{10}$').hasMatch(telefono)) {
      return _aviso('El teléfono debe tener 10 dígitos');
    }
    if (!RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$').hasMatch(email)) {
      return _aviso('Escribe un correo válido');
    }
    if (!(_tiene8 && _tieneMayuscula && _tieneNumero)) {
      return _aviso('La contraseña no cumple los requisitos de seguridad');
    }
    if (password != _confirm.text) {
      return _aviso('Las contraseñas no coinciden');
    }

    setState(() => _isLoading = true);
    try {
      await UserService().registrarUsuario(
        UserModel(
          nombre: nombre,
          email: email,
          password: password,
          telefono: telefono,
          direccion: '',
          rol: 'usuario',
        ),
      );
      if (!mounted) return;
      setState(() => _isLoading = false);
      _aviso('¡Registro exitoso! Verifica tu cuenta para continuar');
      Navigator.pushNamed(context, '/verificacion', arguments: email);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _aviso(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6EE),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background-fondo.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
              child: Column(
                children: [
                  _encabezado(),
                  const Text(
                    'REGISTRO',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFD35400),
                      shadows: [
                        Shadow(
                          offset: Offset(2, 2),
                          blurRadius: 4,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _avatar(),
                  const SizedBox(height: 24),
                  _campo('Nombre completo', _nombre),
                  _campo(
                    'Teléfono',
                    _telefono,
                    tipo: TextInputType.phone,
                    formatos: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                  ),
                  _campo('Correo', _email, tipo: TextInputType.emailAddress),
                  _campo('Contraseña', _password, secreto: true, verOjo: true),
                  _reglas(),
                  _campo('Confirmar contraseña', _confirm, secreto: true),
                  const SizedBox(height: 6),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _registrar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE59866),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 45,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 6,
                    ),
                    child: Text(
                      _isLoading ? 'Registrando...' : 'Verificar',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _encabezado() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Material(
          color: Colors.white70,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => Navigator.pop(context),
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: Colors.black87,
              ),
            ),
          ),
        ),
        Image.asset('assets/images/logo-parche.png', height: 64),
      ],
    );
  }

  Widget _avatar() {
    return Stack(
      children: [
        Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFF9F6EE),
            border: Border.all(color: const Color(0xFFE59866), width: 2),
          ),
          child: const Icon(Icons.person, size: 64, color: Color(0xFFE59866)),
        ),
        Positioned(
          bottom: 2,
          right: 2,
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red,
            ),
            padding: const EdgeInsets.all(3),
            child: const Icon(Icons.add, color: Colors.white, size: 16),
          ),
        ),
      ],
    );
  }

  Widget _reglas() {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _regla('Mínimo 8 caracteres', _tiene8),
          _regla('Al menos una letra mayúscula', _tieneMayuscula),
          _regla('Al menos un número', _tieneNumero),
        ],
      ),
    );
  }

  Widget _regla(String texto, bool ok) {
    final color = ok ? Colors.green.shade800 : Colors.black54;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(texto, style: TextStyle(fontSize: 13, color: color)),
        ],
      ),
    );
  }

  Widget _campo(
    String hint,
    TextEditingController controller, {
    TextInputType tipo = TextInputType.text,
    bool secreto = false,
    bool verOjo = false,
    List<TextInputFormatter>? formatos,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F6EE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE59866)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: secreto && !_verPassword,
        keyboardType: tipo,
        inputFormatters: formatos,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
          suffixIcon: verOjo
              ? IconButton(
                  icon: Icon(
                    _verPassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.black54,
                  ),
                  onPressed: () => setState(() => _verPassword = !_verPassword),
                )
              : null,
        ),
      ),
    );
  }
}
