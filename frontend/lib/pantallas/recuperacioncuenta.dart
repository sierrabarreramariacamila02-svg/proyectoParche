import 'package:flutter/material.dart';
import 'confirmacioncodigo.dart';

class RecuperacionCuenta extends StatefulWidget {
  const RecuperacionCuenta({super.key});

  @override
  State<RecuperacionCuenta> createState() => _RecuperacionCuentaState();
}

class _RecuperacionCuentaState extends State<RecuperacionCuenta> {
  static const _crema = Color(0xFFF8F3E8);
  static const _naranja = Color(0xFFC4500F);
  static const _boton = Color(0xFFE8A057);

  final _controlador = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  void _enviarCodigo() {
    final dato = _controlador.text.trim();
    if (dato.isEmpty) {
      setState(() => _error = 'Ingresa tu correo o teléfono');
      return;
    }
    setState(() => _error = null);
    // TODO: aquí llama a tu backend para enviar el código
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ConfirmacionCodigo(destino: dato)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Evita que el teclado deforme o corte el fondo
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background-fondo.png'),
            fit: BoxFit.cover, // Cubre toda la pantalla por completo
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // Logo con resplandor
                  Center(
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFD35400),
                            blurRadius: 15,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/Logo_el_parche.png',
                        height: 110,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.fastfood, size: 100, color: _naranja),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Text(
                    'RECUPERA TU\nCUENTA',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _naranja,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Ingresa el correo o número de teléfono con el que te '
                    'registraste y te enviaremos un código para recuperar '
                    'tu cuenta.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _controlador,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Correo o teléfono',
                      errorText: _error,
                      prefixIcon: const Icon(Icons.mail_outline, color: _naranja),
                      filled: true,
                      fillColor: _crema,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: _boton),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 220,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: _enviarCodigo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _boton,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        'Enviar código',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Divisor y opción para regresar al inicio de sesión
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(color: Colors.black38, thickness: 1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text(
                            '¿Recuerdas tu contraseña? Inicia sesión',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(color: Colors.black38, thickness: 1),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // Texto de Términos y condiciones inferior
                  const Text(
                    'Al continuar, aceptas nuestros Terminos y condiciones y Politicas de privacidad.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}