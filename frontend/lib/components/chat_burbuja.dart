import 'package:flutter/material.dart';

class ChatBurbuja extends StatelessWidget {
  final String texto;
  final bool esUsuario;

  const ChatBurbuja({
    super.key,
    required this.texto,
    required this.esUsuario,
  });

  static const Color _naranja = Color(0xFFE8963F);
  static const Color _crema = Color(0xFFFFF6E3);
  static const Color _rojoOscuro = Color(0xFF8E1B10);
  static const Color _marron = Color(0xFF4A2C1A);

  @override
  Widget build(BuildContext context) {
    final burbuja = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.70,
      ),
      decoration: BoxDecoration(
        color: esUsuario ? _naranja : _crema,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(esUsuario ? 18 : 4),
          bottomRight: Radius.circular(esUsuario ? 4 : 18),
        ),
        border: esUsuario
            ? null
            : Border.all(color: _naranja.withOpacity(0.35), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: esUsuario ? Colors.white : _marron,
          fontSize: 14,
          height: 1.4,
          fontWeight: esUsuario ? FontWeight.w500 : FontWeight.w400,
        ),
      ),
    );

    final avatarBot = Container(
      width: 30,
      height: 30,
      margin: const EdgeInsets.only(right: 8, bottom: 2),
      decoration: const BoxDecoration(
        color: _rojoOscuro,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.lunch_dining_rounded,
        color: Colors.white,
        size: 17,
      ),
    );

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 12 * (1 - value)),
          child: child,
        ),
      ),
      child: Align(
        alignment: esUsuario ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!esUsuario) avatarBot,
              Flexible(child: burbuja),
            ],
          ),
        ),
      ),
    );
  }
}