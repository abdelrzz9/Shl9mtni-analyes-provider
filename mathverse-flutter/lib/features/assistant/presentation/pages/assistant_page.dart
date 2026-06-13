import 'package:flutter/material.dart';

import '../../../../core/theme/app_animations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_spacing.dart';

class AssistantPage extends StatefulWidget {
  const AssistantPage({super.key});
  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> with TickerProviderStateMixin {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <_Message>[];
  bool _isLoading = false;
  late AnimationController _typingController;
  late Animation<double> _typingAnimation;

  static const _suggestedPrompts = [
    'What is a derivative?',
    'How to integrate x^2?',
    'Solve 2x + 5 = 13',
    'What is a matrix?',
    'Explain limits',
  ];

  @override
  void initState() {
    super.initState();
    _typingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _typingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _typingController, curve: Curves.easeInOut),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Message(text, true, DateTime.now()));
      _messageController.clear();
      _isLoading = true;
    });
    _scrollToBottom();
    _processQuery(text);
  }

  void _onPromptTap(String prompt) {
    _messageController.text = prompt;
    _sendMessage();
  }

  Future<void> _processQuery(String query) async {
    try {
      String response;
      final lower = query.toLowerCase();
      if (lower.contains('derivative') || lower.contains('differentiate')) {
        response = 'Use the Derivatives tool to differentiate functions symbolically. Enter a function like x^2 + 3x and get the derivative with step-by-step explanations.';
      } else if (lower.contains('integral') || lower.contains('integrate')) {
        response = 'Use the Integrals tool for definite and indefinite integration. It supports polynomial, trigonometric, and exponential functions.';
      } else if (lower.contains('limit')) {
        response = 'Use the Limits tool to evaluate function limits as x approaches a value. Supports both finite limits and limits at infinity.';
      } else if (lower.contains('matrix')) {
        response = 'Use the Matrix tool for matrix operations including addition, multiplication, determinant, inverse, and eigenvalues.';
      } else if (lower.contains('statistic') || lower.contains('mean') || lower.contains('median') || lower.contains('standard deviation')) {
        response = 'Use the Statistics tool for statistical calculations including mean, median, mode, standard deviation, and more.';
      } else if (lower.contains('taylor')) {
        response = 'Use the Taylor Series tool for series expansion of functions around a point. Specify the order for more accuracy.';
      } else if (lower.contains('graph') || lower.contains('plot')) {
        response = 'Use the Graph tool for function plotting. Enter any function and see its graph with interactive features.';
      } else if (lower.contains('equation') || lower.contains('solve')) {
        response = 'Try the Calculator for solving equations or use specific tools for advanced math operations.';
      } else if (lower.contains('hello') || lower.contains('hi')) {
        response = 'Hello! I\'m your math assistant. I can help you with derivatives, integrals, limits, matrices, statistics, and more. What would you like to explore?';
      } else {
        response = 'I can help you with various math topics. Try asking about derivatives, integrals, limits, matrices, statistics, or graphing. You can also use the specific tools from the navigation menu.';
      }
      await Future.delayed(Duration(milliseconds: 500 + (response.length % 300) * 3));
      if (mounted) {
        setState(() => _messages.add(_Message(response, false, DateTime.now())));
        _scrollToBottom();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _clearChat() {
    setState(() => _messages.clear());
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: AppAnimations.normal,
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
        actions: [
          if (_messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded),
              tooltip: 'Clear chat',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear Chat'),
                    content: const Text('Clear all messages?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () {
                          _clearChat();
                          Navigator.pop(ctx);
                        },
                        child: const Text('Clear', style: TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? _buildWelcomeScreen(theme)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final showHeader = index == 0 || _shouldShowHeader(index);
                      return Column(
                        children: [
                          if (showHeader)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                              child: Text(
                                _formatTime(msg.timestamp),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          _MessageBubble(message: msg),
                          const SizedBox(height: AppSpacing.xs),
                        ],
                      );
                    },
                  ),
          ),
          if (_isLoading)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              alignment: Alignment.centerLeft,
              child: _TypingIndicator(
                animation: _typingAnimation,
                theme: theme,
              ),
            ),
          Container(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.sm, AppSpacing.sm, AppSpacing.sm,
              MediaQuery.of(context).padding.bottom + AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    textInputAction: TextInputAction.send,
                    minLines: 1,
                    maxLines: 4,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Ask about math...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.xxl),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                AnimatedContainer(
                  duration: AppAnimations.fast,
                  decoration: BoxDecoration(
                    color: _messageController.text.trim().isEmpty
                        ? theme.colorScheme.surfaceContainerHighest
                        : theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.send_rounded,
                      color: _messageController.text.trim().isEmpty
                          ? theme.colorScheme.onSurfaceVariant
                          : theme.colorScheme.onPrimary,
                    ),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _shouldShowHeader(int index) {
    if (index == 0) return true;
    final current = _messages[index].timestamp;
    final previous = _messages[index - 1].timestamp;
    return current.difference(previous).inMinutes >= 5;
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) {
      return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildWelcomeScreen(ThemeData theme) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.smart_toy_rounded,
                size: AppSizes.iconMassive,
                color: theme.colorScheme.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              'Math Assistant',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Ask me anything about math!\nI can help with calculations, concepts, and more.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              alignment: WrapAlignment.center,
              children: _suggestedPrompts.map((prompt) {
                return ActionChip(
                  label: Text(prompt, style: theme.textTheme.labelMedium),
                  onPressed: () => _onPromptTap(prompt),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.chip),
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  _Message(this.text, this.isUser, this.timestamp);
}

class _MessageBubble extends StatelessWidget {
  final _Message message;
  const _MessageBubble({required this.message});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: message.isUser
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppRadius.xl).copyWith(
            bottomRight: message.isUser ? Radius.zero : const Radius.circular(AppRadius.xl),
            bottomLeft: message.isUser ? const Radius.circular(AppRadius.xl) : Radius.zero,
          ),
        ),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        child: Text(
          message.text,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: message.isUser
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  final Animation<double> animation;
  final ThemeData theme;
  const _TypingIndicator({required this.animation, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.xl).copyWith(
          bottomLeft: Radius.zero,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return Padding(
            padding: EdgeInsets.only(right: index < 2 ? AppSpacing.xs : 0),
            child: AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                final delay = index * 0.2;
                final value = ((animation.value + delay) % 1.0);
                final size = 6.0 + value * 4.0;
                return Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}
