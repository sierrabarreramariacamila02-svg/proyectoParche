import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6EE), // Fondo crema de respaldo
      body: Stack(
        children: [
          // 1. Imagen de fondo que ocupa absolutamente TODA la pantalla de extremo a extremo
          Positioned.fill(
            child: Image.asset(
              'assets/images/background-fondo.png',
              fit: BoxFit.cover,
            ),
          ),

          // 2. Contenido con scroll que llena la pantalla verticalmente
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 10,
                        ),
                        child: Column(
                          children: [
                            // Encabezado
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.arrow_back_ios_new,
                                    color: Colors.black,
                                    size: 22,
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                Image.asset(
                                  'assets/images/logo-parche.png',
                                  height: 100,
                                ),
                              ],
                            ),

                            // Título REGISTRO
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
                            SizedBox(height: 30),

                            // Avatar de foto de perfil
                            Stack(
                              children: [
                                Container(
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFF9F6EE),
                                    border: Border.all(
                                      color: const Color(0xFFE59866),
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    size: 70,
                                    color: Color(0xFFE59866),
                                  ),
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
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 30),

                            // Campos de texto
                            _buildInputField('Nombre completo'),
                            _buildInputField('Telefono'),
                            _buildInputField('Correo'),
                            _buildInputField('Contraseña', isPassword: true),
                            _buildInputField(
                              'Confirmar contraseña',
                              isPassword: true,
                            ),
                            const SizedBox(height: 20),

                            // Botón Verificar
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/verificacion');
                              },
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
                              child: const Text(
                                'Verificar',
                                style: TextStyle(
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
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String hint, {bool isPassword = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
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
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
        ),
      ),
    );
  }
}