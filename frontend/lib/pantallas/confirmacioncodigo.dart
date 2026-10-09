import 'dart:async';
import 'package:elparchee/components/productos.dart'; // Asegúrate de que esta ruta sea la correcta para tu pantalla home/productos
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ConfirmacionCodigo extends StatefulWidget {
  final String destino;
  const ConfirmacionCodigo({super.key, this.destino = ''});

  @override
  State<ConfirmacionCodigo> createState() => _ConfirmacionCodigoState();
}

class _ConfirmacionCodigoState extends State<ConfirmacionCodigo> {
  static const _crema = Color(0xFFF8F3E8);
  static const _naranja = Color(0xFFC4500F);
  static const _boton = Color(0xFFE8A057);

  final _controladores = List.generate(6, (_) => TextEditingController());
  final _focos = List.generate(6, (_) => FocusNode());
  final _nuevaPassController = TextEditingController();
  Timer? _timer;
  int _segundos = 600;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_segundos == 0) return t.cancel();
      setState(() => _segundos--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controladores) c.dispose();
    for (var f in _focos) f.dispose();
    _nuevaPassController.dispose();
    super.dispose();
  }

  String get _tiempo => '${(_segundos ~/ 60).toString().padLeft(2, '0')}:${(_segundos % 60).toString().padLeft(2, '0')}';

  void _verificar() {
    final codigo = _controladores.map((c) => c.text).join();
    if (codigo.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa los 6 dígitos')),
      );
      return;
    }
    
    // NAVEGACIÓN HACIA HOME / PRODUCTOS
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Productos()),
      (route) => false, // Esto borra las pantallas anteriores del historial para que no pueda volver atrás con el botón de retroceso
    );
  }

  Widget _casilla(int i) => Container(
    width: 40, height: 48,
    margin: const EdgeInsets.symmetric(horizontal: 4),
    decoration: BoxDecoration(color: Colors.white54, border: Border.all(color: _boton), borderRadius: BorderRadius.circular(4)),
    child: TextField(
      controller: _controladores[i], focusNode: _focos[i], textAlign: TextAlign.center,
      keyboardType: TextInputType.number, maxLength: 1,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      decoration: const InputDecoration(counterText: '', border: InputBorder.none),
      onChanged: (v) {
        if (v.isNotEmpty && i < 5) _focos[i + 1].requestFocus();
        if (v.isEmpty && i > 0) _focos[i - 1].requestFocus();
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: _crema,
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/images/background-fondo.png', fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox.shrink())),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Center(
                    child: Container(
                      
                      child: Image.asset('assets/images/Logo_el_parche.png', height: 110, errorBuilder: (_, __, ___) => const Icon(Icons.fastfood, size: 100, color: _naranja)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('CONFIRMA TU\nCÓDIGO', textAlign: TextAlign.center, style: TextStyle(color: _naranja, fontSize: 34, fontWeight: FontWeight.w900, height: 1.1)),
                  const SizedBox(height: 12),
                  const Text('Confirma el código de 6 dígitos que te enviamos a tu correo o teléfono.', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 16),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(6, _casilla)),
                  const SizedBox(height: 12),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.timer_outlined, size: 16, color: _naranja),
                    const SizedBox(width: 6),
                    Text('El código expira en $_tiempo minutos', style: const TextStyle(fontSize: 12)),
                  ]),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nuevaPassController, obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Nueva contraseña',
                      hintStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                      prefixIcon: const Icon(Icons.lock_outline, color: _naranja),
                      filled: true, fillColor: Colors.white54,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: _boton)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: _boton)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 220, height: 46,
                    child: ElevatedButton(
                      onPressed: _verificar, // <-- Vinculado a la función de verificación y navegación
                      style: ElevatedButton.styleFrom(backgroundColor: _boton, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
                      child: const Text('Verificar', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(onPressed: () => setState(() => _segundos = 600), child: const Text('Reenviar código', style: TextStyle(color: Colors.black, fontSize: 12))),
                  const SizedBox(height: 15),
                  const Text('Al continuar, aceptas nuestros Terminos y condiciones y Politicas de privacidad.', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}