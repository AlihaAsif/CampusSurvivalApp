import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../domain/chat_message.dart';
import 'assistant_controller.dart';

class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  static const List<String> _suggestions = [
    "What's my next class?",
    "How many classes can I miss in Data Structures?",
    "How much can I spend per day?",
    "Where is the library?",
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSend([String? text]) {
    final query = text ?? _textController.text;
    if (query.trim().isEmpty) return;

    _textController.clear();
    setState(() {});
    ref.read(assistantControllerProvider.notifier).send(query);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final state = ref.watch(assistantControllerProvider);

    ref.listen(assistantControllerProvider, (previous, next) {
      if (previous?.messages.length != next.messages.length ||
          previous?.isSending != next.isSending) {
        _scrollToBottom();
      }
    });

    final hasMessages = state.messages.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Campus Assistant',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Online · Powered by Gemini',
                  style: TextStyle(
                    fontSize: 11,
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (hasMessages)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Clear chat',
              onPressed: () =>
                  ref.read(assistantControllerProvider.notifier).clear(),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: hasMessages
                ? ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(AppSpacing.screenH),
                    itemCount:
                        state.messages.length + (state.isSending ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < state.messages.length) {
                        final msg = state.messages[index];
                        return _ChatBubble(message: msg);
                      }
                      return const _TypingIndicatorBubble();
                    },
                  )
                : _EmptyState(
                    suggestions: _suggestions,
                    onTapSuggestion: (suggestion) {
                      _handleSend(suggestion);
                    },
                  ),
          ),

          if (state.errorMessage != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenH,
                vertical: AppSpacing.xs,
              ),
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: scheme.errorContainer,
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline,
                      size: 20, color: scheme.onErrorContainer),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      state.errorMessage!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenH,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: scheme.surface,
              border: Border(
                top: BorderSide(
                  color: BrandColors.orange.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      minLines: 1,
                      maxLines: 4,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Ask about classes, budget, campus...',
                        filled: true,
                        fillColor: const Color(0xFFF4F6FB),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(
                            color: BrandColors.orange,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: BrandColors.orange,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          BrandColors.orange.withValues(alpha: 0.4),
                      disabledForegroundColor: Colors.white,
                    ),
                    onPressed: (_textController.text.trim().isEmpty ||
                            state.isSending)
                        ? null
                        : () => _handleSend(),
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.suggestions,
    required this.onTapSuggestion,
  });

  final List<String> suggestions;
  final ValueChanged<String> onTapSuggestion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: BrandColors.orange.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              size: 48,
              color: BrandColors.orange,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'AI Campus Assistant',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: BrandColors.navy,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Ask me anything about your timetable, attendance, budget, deadlines or campus places.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            alignment: WrapAlignment.center,
            children: suggestions.map((suggestion) {
              return ActionChip(
                label: Text(
                  suggestion,
                  style: const TextStyle(
                    color: BrandColors.navy,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                backgroundColor: Colors.white,
                onPressed: () => onTapSuggestion(suggestion),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: BrandColors.orange.withValues(alpha: 0.3),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final ChatMessage message;

  Widget _buildFormattedText(
      String text, TextStyle? baseStyle, Color textColor) {
    final parts = text.split('**');
    if (parts.length == 1) {
      return Text(text, style: baseStyle?.copyWith(color: textColor));
    }

    final spans = <TextSpan>[];
    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isEmpty) continue;
      final isBold = i % 2 == 1;
      spans.add(
        TextSpan(
          text: parts[i],
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold
                ? (textColor == Colors.white ? Colors.white : BrandColors.navy)
                : textColor,
          ),
        ),
      );
    }

    return RichText(
      text: TextSpan(
        style: baseStyle?.copyWith(color: textColor, height: 1.45),
        children: spans,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isUser = message.isUser;

    final maxBubbleWidth = MediaQuery.of(context).size.width * 0.78;

    final textColor = isUser ? Colors.white : scheme.onSurface;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8, top: 2),
              decoration: BoxDecoration(
                color: BrandColors.orange.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: BrandColors.orange.withValues(alpha: 0.3),
                ),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                size: 16,
                color: BrandColors.orange,
              ),
            ),
          ],
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxBubbleWidth),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm + 2,
              ),
              decoration: BoxDecoration(
                color: isUser
                    ? BrandColors.navy
                    : Colors.white,
                border: isUser
                    ? null
                    : Border.all(
                        color: BrandColors.orange.withValues(alpha: 0.2),
                        width: 1,
                      ),
                boxShadow: [
                  BoxShadow(
                    color: isUser
                        ? BrandColors.navy.withValues(alpha: 0.15)
                        : Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
              ),
              child: _buildFormattedText(
                message.text,
                theme.textTheme.bodyMedium,
                textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingIndicatorBubble extends StatelessWidget {
  const _TypingIndicatorBubble();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 8, top: 2),
            decoration: BoxDecoration(
              color: BrandColors.orange.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: BrandColors.orange.withValues(alpha: 0.3),
              ),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              size: 16,
              color: BrandColors.orange,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm + 2,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: BrandColors.orange.withValues(alpha: 0.2),
                width: 1,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: BrandColors.orange,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Thinking...',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
