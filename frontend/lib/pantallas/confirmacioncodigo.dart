import 'dart:async';
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
  Timer? _timer;
  int _segundos = 600;

  @override
  void initState() {
    super.initState();
    _iniciarTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controladores) {
      c.dispose();
    }
    for (final f in _focos) {
      f.dispose();
    }
    super.dispose();
  }

  void _iniciarTimer() {
    _timer?.cancel();
    _segundos = 600;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_segundos == 0) return t.cancel();
      setState(() => _segundos--);
    });
  }

  String get _tiempo =>
      '${(_segundos ~/ 60).toString().padLeft(2, '0')}:'
      '${(_segundos % 60).toString().padLeft(2, '0')}';

  void _verificar() {
    final codigo = _controladores.map((c) => c.text).join();
    if (codigo.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa los 6 dígitos')),
      );
      return;
    }
    // TODO: aquí valida el código con tu backend
  }

  Widget _casilla(int i) {
    return Container(
      width: 40,
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white54,
        border: Border.all(color: _boton),
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextField(
        controller: _controladores[i],
        focusNode: _focos[i],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        onChanged: (v) {
          if (v.isNotEmpty && i < 5) _focos[i + 1].requestFocus();
          if (v.isEmpty && i > 0) _focos[i - 1].requestFocus();
        },
      ),
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
                  const SizedBox(height: 16),
                  Image.asset(
                    'assets/images/logo_elparche.png',
                    height: 150,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.fastfood, size: 100, color: _naranja),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'CONFIRMA TU\nCÓDIGO',
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
                    'Confirma el código de 6 dígitos que te enviamos a tu '
                    'correo o teléfono.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, _casilla),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.timer_outlined, size: 16, color: _naranja),
                      const SizedBox(width: 6),
                      Text(
                        'El código expira en $_tiempo minutos',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 220,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: _verificar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _boton,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        'Verificar',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () => setState(_iniciarTimer),
                    child: const Text(
                      'Reenviar código',
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