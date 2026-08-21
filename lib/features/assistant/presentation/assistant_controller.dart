import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/gemini_assistant_repository.dart';
import '../domain/assistant_repository.dart';
import '../domain/chat_message.dart';
import 'assistant_context.dart';

final assistantRepositoryProvider = Provider<AssistantRepository>((ref) {
  return GeminiAssistantRepository();
});

class AssistantState {
  const AssistantState({
    this.messages = const [],
    this.isSending = false,
    this.errorMessage,
  });

  final List<ChatMessage> messages;
  final bool isSending;
  final String? errorMessage;

  AssistantState copyWith({
    List<ChatMessage>? messages,
    bool? isSending,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AssistantState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AssistantController extends Notifier<AssistantState> {
  @override
  AssistantState build() => const AssistantState();

  Future<void> send(String question) async {
    final trimmed = question.trim();
    if (trimmed.isEmpty || state.isSending) return;

    final userMsg = ChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      text: trimmed,
      isUser: true,
      sentAt: DateTime.now(),
    );

    final history = state.messages;

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isSending: true,
      clearError: true,
    );

    try {
      final contextText = ref.read(assistantContextProvider);
      final repo = ref.read(assistantRepositoryProvider);

      final replyText = await repo.ask(
        question: trimmed,
        context: contextText,
        history: history,
      );

      final assistantMsg = ChatMessage(
        id: (DateTime.now().microsecondsSinceEpoch + 1).toString(),
        text: replyText,
        isUser: false,
        sentAt: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, assistantMsg],
        isSending: false,
      );
    } catch (e, stack) {
      debugPrint('AssistantController error: $e\n$stack');
      state = state.copyWith(
        isSending: false,
        errorMessage: 'Error: $e',
      );
    }
  }

  void clear() {
    state = const AssistantState();
  }
}

final assistantControllerProvider =
    NotifierProvider<AssistantController, AssistantState>(
        AssistantController.new);
