import 'package:flutter/material.dart';

class ChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onEnviar;
  final bool cargando;

  const ChatInputField({
    super.key,
    required this.controller,
    required this.onEnviar,
    required this.cargando,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6E3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: const Color(0xFFE8963F).withOpacity(0.5),
                    ),
                  ),
                  child: TextField(
                    controller: controller,
                    enabled: !cargando,
                    textInputAction: TextInputAction.send,
                    textCapitalization: TextCapitalization.sentences,
                    style: const TextStyle(
                      color: Color(0xFF4A2C1A),
                      fontSize: 14,
                    ),
                    cursorColor: const Color(0xFF8E1B10),
                    decoration: const InputDecoration(
                      hintText: 'Pregunta por platos, precios...',
                      hintStyle: TextStyle(color: Colors.black38, fontSize: 13),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    ),
                    onSubmitted: (_) => onEnviar(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: cargando ? null : onEnviar,
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFE8963F),
                  disabledBackgroundColor: const Color(0xFFE8963F).withOpacity(0.4),
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white70,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(12),
                ),
                icon: const Icon(Icons.send_rounded, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}