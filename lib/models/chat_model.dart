class ChatModel {
  final String text;
  final bool isSender;

  ChatModel({
    required this.text,
    this.isSender = true,
  });

  ChatModel copyWith({
    String? text,
    bool? isSender,
  }) {
    return ChatModel(
      text: text ?? this.text,
      isSender: isSender ?? this.isSender,
    );
  }
}
