class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.sentAt,
  });

  final String id;
  final String text;
  final bool isUser;
  final DateTime sentAt;
}
