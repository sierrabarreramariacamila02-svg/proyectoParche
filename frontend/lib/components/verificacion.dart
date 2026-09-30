import 'package:flutter/material.dart';
import 'package:parche/components/bienvenidos.dart';

class Verification extends StatefulWidget {
  const Verification({super.key});

  @override
  State<Verification> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<Verification> {
  final List<TextEditingController> _ctr = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _fn = List.generate(6, (_) => FocusNode());
  bool _acceptTerms = false;

  @override
  void dispose() {
    for (var c in _ctr) {
      c.dispose();
    }
    for (var f in _fn) {
      f.dispose();
    }
    super.dispose();
  }

  void _onChanged(String val, int i) {
    if (val.isNotEmpty && i < 5) _fn[i + 1].requestFocus();
    if (val.isEmpty && i > 0) _fn[i - 1].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6EE),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.black,
                      size: 24,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Image.asset('assets/images/logo-parche.png', height: 100),
                ],
              ),

              const SizedBox(height: 80),
              const Text(
                'INGRESA EL CODIGO DE\nVERIFICACIÓN',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  shadows: [
                    Shadow(
                      offset: Offset(2, 2),
                      blurRadius: 4,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildBox(0),
                  const SizedBox(width: 6),
                  _buildBox(1),
                  const SizedBox(width: 6),
                  _buildBox(2),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '-',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE59866),
                      ),
                    ),
                  ),
                  _buildBox(3),
                  const SizedBox(width: 6),
                  _buildBox(4),
                  const SizedBox(width: 6),
                  _buildBox(5),
                ],
              ),
              const SizedBox(height: 35),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _acceptTerms = !_acceptTerms),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE59866),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: _acceptTerms
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Acepta terminos y condiciones',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 80),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Bienvenidos()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE59866),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'Crear cuenta.',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBox(int i) {
    return Container(
      width: 42,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF9F6EE),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE59866), width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 3)),
        ],
      ),
      child: TextField(
        controller: _ctr[i],
        focusNode: _fn[i],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        onChanged: (v) => _onChanged(v, i),
      ),
    );
  }
}
