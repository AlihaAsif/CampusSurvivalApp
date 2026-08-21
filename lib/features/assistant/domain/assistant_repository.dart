import 'chat_message.dart';

abstract class AssistantRepository {
  Future<String> ask({
    required String question,
    required String context,
    required List<ChatMessage> history,
  });
}
