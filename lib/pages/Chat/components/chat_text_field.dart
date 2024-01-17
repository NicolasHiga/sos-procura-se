import 'package:flutter/material.dart';

class ChatTextField extends StatefulWidget {
  final bool sendEnabled;
  final void Function(String message) onMessage;

  const ChatTextField({super.key, required this.onMessage, this.sendEnabled = true});

  @override
  State<ChatTextField> createState() => _ChatFieldState();
}

class _ChatFieldState extends State<ChatTextField> {
  final textController = TextEditingController();
  final focusNode = FocusNode();

  _senderMessage() {
    if (widget.sendEnabled) {
      final message = textController.text;
      if (message.isNotEmpty) {
        widget.onMessage(message);
        textController.text = '';
      }
    }

    focusNode.requestFocus();
  }

  bool get isButtonEnabled => textController.text.isNotEmpty && widget.sendEnabled;

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        focusNode: focusNode,
        controller: textController,
        onSubmitted: (value) {
          _senderMessage();
        },
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          fillColor: Colors.white,
          filled: true,
          hintText: 'Sua mensagem...',
          suffixIcon: AnimatedBuilder(
            animation: textController,
            builder: (context, _) {
              return IconButton(
                onPressed: !isButtonEnabled ? null : _senderMessage,
                icon: const Icon(Icons.send),
              );
            },
          ),
        ),
      ),
    );
  }
}