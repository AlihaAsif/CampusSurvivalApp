import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../../../core/config/gemini_config.dart';
import '../domain/assistant_repository.dart';
import '../domain/chat_message.dart';

class GeminiAssistantRepository implements AssistantRepository {
  static const _systemInstruction =
      'You are a campus assistant for a Pakistani university student. '
      'Answer from the supplied context plus general campus knowledge. '
      'Keep answers short and plain. If the context doesn\'t have the answer, say so — '
      'never invent class times, attendance numbers, or amounts.';

  @override
  Future<String> ask({
    required String question,
    required String context,
    required List<ChatMessage> history,
  }) async {
    final recentHistory = history.length > 6
        ? history.sublist(history.length - 6)
        : history;

    final historyContent = recentHistory.map((msg) {
      return msg.isUser
          ? Content('user', [TextPart(msg.text)])
          : Content('model', [TextPart(msg.text)]);
    }).toList();

    debugPrint('Gemini model: ${GeminiConfig.model}');

    final model = GenerativeModel(
      model: GeminiConfig.model,
      apiKey: GeminiConfig.apiKey,
      systemInstruction: Content.system(_systemInstruction),
    );

    final chat = model.startChat(history: historyContent);
    final prompt = 'CONTEXT:\n$context\n\nQUESTION: $question';
    final response = await chat.sendMessage(Content.text(prompt));

    return response.text ?? '';
  }
}
