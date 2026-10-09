import 'package:flutter/material.dart';

class ChatInputField extends StatefulWidget {
  final TextEditingController controlador;
  final VoidCallback onEnviar;

  const ChatInputField({
    super.key,
    required this.controlador,
    required this.onEnviar,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: widget.controlador,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => widget.onEnviar(),
                decoration: InputDecoration(
                  hintText: 'Escribe tu mensaje...',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.orange,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: widget.onEnviar,
              ),
            ),
          ],
        ),
      ),
    );
  }
}