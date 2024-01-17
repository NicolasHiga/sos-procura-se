import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sos_app/core/config/env.dart';
import 'package:sos_app/core/services/chat/chat_provider.dart';

class ApiService {
  static final _apiKey = Env.instance['GPT_APIKEY'] ?? '';
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  static Future<String> sendMessage({required String message, required BuildContext ctx}) async {
    final conversationProvider = Provider.of<ConversationProvider>(ctx, listen: false);
    conversationProvider.addMessage({"role": "user", "content": message});
    
    String chatResponse = '';
    try {      
      var response = await http.post(Uri.parse(_baseUrl),
          headers: {
            'Authorization': 'Bearer $_apiKey',
            "Content-type": "application/json",
          },
          body: jsonEncode({
            "model": "gpt-3.5-turbo",
            "messages": conversationProvider.conversation,
            "temperature": 0.5
          }));

      Map jsonResponse = json.decode(utf8.decode(response.bodyBytes));

      if (jsonResponse["error"] != null) {
        throw HttpException(jsonResponse["error"]["message"]);
      }

      if(jsonResponse["choices"].length > 0) {
        chatResponse = jsonResponse["choices"][0]["message"]["content"];
        conversationProvider.addMessage({"role": "assistant", "content": chatResponse});
        return chatResponse;
      }      
    } catch (e) {
      log("error: $e");
      throw Exception("Erro ao enviar mensagem ao GPT: $e");
    }
    return chatResponse;
  }
}
