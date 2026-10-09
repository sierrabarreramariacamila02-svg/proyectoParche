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
      backgroundColor: _crema,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/fondo_hamburguesas.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Image.asset(
                    'assets/images/logo_elparche.png',
                    height: 150,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.fastfood, size: 100, color: _naranja),
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
                  const SizedBox(height: 40),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Volver al inicio de sesión',
                      style: TextStyle(color: Colors.black, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}