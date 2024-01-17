import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sos_app/core/services/chat/api_service.dart';
import 'package:sos_app/core/services/chat/chat_provider.dart';
import 'package:sos_app/core/ui/helpers/messages.dart';
import 'package:sos_app/models/chat_model.dart';
import 'package:sos_app/pages/Chat/components/chat_bubble.dart';
import 'package:sos_app/pages/Chat/components/chat_text_field.dart';

class MiloChat extends StatefulWidget {
  const MiloChat({super.key});

  @override
  State<MiloChat> createState() => _MiloChatState();
}

class _MiloChatState extends State<MiloChat> {
  final chatMsgs = [
    ChatModel(
        text: 'Olá, eu sou Milo. Como posso lhe ajudar?', isSender: false),
  ];
  String? miloResponse;

  bool isLoading = false;

  void _sendMessage(String message) async {
    setState(() {
      setState(
          () => chatMsgs.insert(0, ChatModel(text: message, isSender: true)));
      isLoading = true;
    });

    try {
      miloResponse =
          await ApiService.sendMessage(message: message, ctx: context);
      if (miloResponse != '') {
        setState(() => chatMsgs.insert(
            0, ChatModel(text: miloResponse!, isSender: false)));
      } else {
        // ignore: use_build_context_synchronously
        Messages.showError(context, "Erro de conexão. Tente novamente.");
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      Messages.showError(context, "Erro de conexão. Tente novamente.");
      log("Erro ao enviar resposta ao Milo: $e");
      throw Exception("Erro ao enviar resposta ao Milo: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          title: Row(
            children: [
              Image.asset(
                'assets/images/milos-head.png',
                height: 30,
              ),
              const SizedBox(
                width: 8,
              ),
              const Text('Milo'),
            ],
          ),
          leading: IconButton(
            icon: Icon(Icons.adaptive.arrow_back),
            onPressed: () {
              final conversationProvider = Provider.of<ConversationProvider>(context, listen: false);
              conversationProvider.clearConversation();
              Navigator.of(context).pushReplacementNamed('/home/milo');
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(
                    bottom: 10,
                  ),
                  reverse: true,
                  itemCount: chatMsgs.length,
                  itemBuilder: (context, index) {
                    return ChatBubble(model: chatMsgs[index], index: index,);
                  },
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: ChatTextField(
                  sendEnabled: !isLoading,
                  onMessage: _sendMessage,
                ),
              ),
              if (isLoading)
                const Align(
                  alignment: Alignment.topCenter,
                  child: LinearProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
