import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

class AssistantPage extends StatefulWidget {
  const AssistantPage({super.key});

  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> {
  final _messageController = TextEditingController();
  final _messages = <_Message>[];
  bool _isLoading = false;

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_Message(text, true));
      _messageController.clear();
      _isLoading = true;
    });

    _processQuery(text);
  }

  Future<void> _processQuery(String query) async {
    try {
      String response;
      if (query.contains('derivative') || query.contains('differentiate')) {
        response = 'Use the Derivatives tool to differentiate functions symbolically.';
      } else if (query.contains('integral') || query.contains('integrate')) {
        response = 'Use the Integrals tool for definite and indefinite integration.';
      } else if (query.contains('limit')) {
        response = 'Use the Limits tool to evaluate function limits.';
      } else if (query.contains('matrix')) {
        response = 'Use the Matrix tool for matrix operations.';
      } else if (query.contains('statistic') || query.contains('mean') || query.contains('median')) {
        response = 'Use the Statistics tool for statistical calculations.';
      } else if (query.contains('taylor')) {
        response = 'Use the Taylor Series tool for series expansion.';
      } else if (query.contains('graph') || query.contains('plot')) {
        response = 'Use the Graph tool for function plotting.';
      } else if (query.contains('help')) {
        response = 'MathApp provides: Calculator, Derivatives, Integrals, Limits, Taylor Series, DL, Matrix, Statistics, Graph, OCR, and History features.';
      } else {
        response = 'Try the Calculator for basic expressions or the specific tool for advanced math operations.';
      }

      await Future.delayed(const Duration(milliseconds: 300));
      setState(() => _messages.add(_Message(response, false)));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Assistant')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.md),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _MessageBubble(message: msg);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(AppDimensions.sm),
              child: LinearProgressIndicator(),
            ),
          Container(
            padding: const EdgeInsets.all(AppDimensions.sm),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Ask about math...',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: AppColors.primary),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Message {
  final String text;
  final bool isUser;

  _Message(this.text, this.isUser);
}

class _MessageBubble extends StatelessWidget {
  final _Message message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.sm),
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: AppDimensions.sm),
        decoration: BoxDecoration(
          color: message.isUser ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius).copyWith(
            bottomRight: message.isUser ? Radius.zero : const Radius.circular(AppDimensions.cardRadius),
            bottomLeft: message.isUser ? const Radius.circular(AppDimensions.cardRadius) : Radius.zero,
          ),
        ),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? AppColors.onPrimary : AppColors.onSurface,
            fontSize: AppDimensions.fontSizeMd,
          ),
        ),
      ),
    );
  }
}
