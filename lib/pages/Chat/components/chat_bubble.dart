import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:sos_app/core/ui/styles/colors_app.dart';
import 'package:sos_app/models/chat_model.dart';

class ChatBubble extends StatelessWidget {
  final ChatModel model;
  final int index;

  const ChatBubble({super.key, required this.model, required this.index});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: model.isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
          constraints: const BoxConstraints(
            maxWidth: 250, // Defina o limite máximo de largura aqui
          ),
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: model.isSender ? ColorsApp.instance.primary : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(1, 2),
              ),
            ],
          ),
          child: (!model.isSender && index == 0)
              ? DefaultTextStyle(
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                  child: AnimatedTextKit(
                      isRepeatingAnimation: false,
                      repeatForever: false,
                      displayFullTextOnTap: true,
                      totalRepeatCount: 1,
                      animatedTexts: [TyperAnimatedText(model.text.trim())]),
                )
              : Text(
                  model.text,
                  style: TextStyle(
                    color: model.isSender ? Colors.white : Colors.black,
                    fontSize: 16,
                  ),
                )),
    );
  }
}
