import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/responsive.dart';
import '../../../../core/theme/app_animations.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/repositories/calculator_repository_impl.dart';
import '../../domain/usecases/evaluate_expression.dart';
import '../bloc/calculator_bloc.dart';

String _friendlyErrorMessage(String message) {
  final lower = message.toLowerCase();
  if (lower.contains('network') ||
      lower.contains('connection') ||
      lower.contains('socket')) {
    return 'Check your internet connection and try again';
  }
  if (lower.contains('invalid') ||
      lower.contains('syntax') ||
      lower.contains('parse')) {
    return 'Please check your expression syntax';
  }
  if (lower.contains('divide by zero')) {
    return 'Cannot divide by zero';
  }
  if (lower.contains('timeout')) {
    return 'Calculation took too long. Please try again';
  }
  if (lower.contains('math') || lower.contains('domain')) {
    return 'Math error: please check your input';
  }
  return 'Something went wrong. Please try again';
}

class CalculatorPage extends StatelessWidget {
  const CalculatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Calculator',
          style: context.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocProvider(
        create: (_) => CalculatorBloc(
          evaluateExpression: EvaluateExpression(CalculatorRepositoryImpl()),
        ),
        child: const _CalculatorBody(),
      ),
    );
  }
}

class _CalculatorBody extends StatefulWidget {
  const _CalculatorBody();

  @override
  State<_CalculatorBody> createState() => _CalculatorBodyState();
}

class _CalculatorBodyState extends State<_CalculatorBody> {
  String _currentExpression = '';
  final _expressionController = TextEditingController();
  final _expressionScrollController = ScrollController();

  void _append(String value) {
    setState(() {
      _currentExpression += value;
      _expressionController.text = _currentExpression;
    });
    _scrollToEnd();
    context.read<CalculatorBloc>().add(ExpressionChanged(_currentExpression));
  }

  void _clear() {
    setState(() {
      _currentExpression = '';
      _expressionController.text = '';
    });
    context.read<CalculatorBloc>().add(const ClearExpression());
  }

  void _backspace() {
    if (_currentExpression.isNotEmpty) {
      setState(() {
        _currentExpression = _currentExpression.substring(
            0, _currentExpression.length - 1);
        _expressionController.text = _currentExpression;
      });
      _scrollToEnd();
      context
          .read<CalculatorBloc>()
          .add(ExpressionChanged(_currentExpression));
    }
  }

  void _calculate() {
    if (_currentExpression.isEmpty) return;
    context.read<CalculatorBloc>().add(Calculate(_currentExpression));
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_expressionScrollController.hasClients) {
        _expressionScrollController.animateTo(
          _expressionScrollController.position.maxScrollExtent,
          duration: AppAnimations.fast,
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatResult(double result) {
    if (result.isNaN) return 'Error';
    if (result.isInfinite) return result.isNegative ? '-Infinity' : 'Infinity';
    if (result == result.roundToDouble()) return result.toInt().toString();
    return result.toStringAsFixed(10).replaceAll(RegExp(r'\.?0+$'), '');
  }

  @override
  void dispose() {
    _expressionController.dispose();
    _expressionScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity != null &&
                  details.primaryVelocity! > 400) {
                _clear();
              }
            },
            child: BlocBuilder<CalculatorBloc, CalculatorState>(
              builder: (context, state) {
                return Container(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SingleChildScrollView(
                        controller: _expressionScrollController,
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          _expressionController.text.isEmpty
                              ? '0'
                              : _expressionController.text,
                          style: context.textTheme.headlineSmall?.copyWith(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w400,
                            color: context.colorScheme.onSurface.withAlpha(160),
                            letterSpacing: 1.2,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      if (state is CalculatorLoading)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.sm),
                          child: SizedBox(
                            width: AppSizes.iconLarge,
                            height: AppSizes.iconLarge,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: context.colorScheme.primary,
                            ),
                          ),
                        )
                      else if (state is CalculatorResultState)
                        AnimatedSwitcher(
                          duration: AppAnimations.normal,
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.3),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: Text(
                            _formatResult(state.result.result),
                            key: ValueKey('${state.result.result}_${state.result.timestamp}'),
                            style: context.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w300,
                              color: context.colorScheme.primary,
                              letterSpacing: -0.5,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        )
                      else if (state is CalculatorError)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.xs),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                size: AppSizes.iconSmall,
                                color: context.colorScheme.error,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Flexible(
                                child: Text(
                                  _friendlyErrorMessage(state.message),
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    color: context.colorScheme.error,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainerLow,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.xxl),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.xs,
              AppSpacing.md,
              AppSpacing.xs,
              MediaQuery.of(context).padding.bottom + AppSpacing.sm,
            ),
            child: _buildButtonGrid(),
          ),
        ),
      ],
    );
  }

  Widget _buildButtonGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        const gap = AppSpacing.xs;
        const totalGap = gap * 3;
        final btnWidth = (width - totalGap) / 4;
        final btnHeight = btnWidth * 0.88;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRow([
              _CalcButton(
                label: 'C',
                color: context.colorScheme.error,
                onTap: _clear,
                width: btnWidth,
                height: btnHeight,
              ),
              _CalcButton(
                label: '(',
                color: context.colorScheme.secondaryContainer,
                textColor: context.colorScheme.onSecondaryContainer,
                onTap: () => _append('('),
                width: btnWidth,
                height: btnHeight,
              ),
              _CalcButton(
                label: ')',
                color: context.colorScheme.secondaryContainer,
                textColor: context.colorScheme.onSecondaryContainer,
                onTap: () => _append(')'),
                width: btnWidth,
                height: btnHeight,
              ),
              _CalcButton(
                label: '\u00F7',
                color: context.colorScheme.primary,
                onTap: () => _append('/'),
                width: btnWidth,
                height: btnHeight,
              ),
            ], gap: gap),
            const SizedBox(height: gap),
            _buildRow([
              _CalcButton(
                label: '7',
                color: context.colorScheme.surfaceContainerHighest,
                textColor: context.colorScheme.onSurface,
                onTap: () => _append('7'),
                width: btnWidth,
                height: btnHeight,
              ),
              _CalcButton(
                label: '8',
                color: context.colorScheme.surfaceContainerHighest,
                textColor: context.colorScheme.onSurface,
                onTap: () => _append('8'),
                width: btnWidth,
                height: btnHeight,
              ),
              _CalcButton(
                label: '9',
                color: context.colorScheme.surfaceContainerHighest,
                textColor: context.colorScheme.onSurface,
                onTap: () => _append('9'),
                width: btnWidth,
                height: btnHeight,
              ),
              _CalcButton(
                label: '\u00D7',
                color: context.colorScheme.primary,
                onTap: () => _append('*'),
                width: btnWidth,
                height: btnHeight,
              ),
            ], gap: gap),
            const SizedBox(height: gap),
            _buildRow([
              _CalcButton(
                label: '4',
                color: context.colorScheme.surfaceContainerHighest,
                textColor: context.colorScheme.onSurface,
                onTap: () => _append('4'),
                width: btnWidth,
                height: btnHeight,
              ),
              _CalcButton(
                label: '5',
                color: context.colorScheme.surfaceContainerHighest,
                textColor: context.colorScheme.onSurface,
                onTap: () => _append('5'),
                width: btnWidth,
                height: btnHeight,
              ),
              _CalcButton(
                label: '6',
                color: context.colorScheme.surfaceContainerHighest,
                textColor: context.colorScheme.onSurface,
                onTap: () => _append('6'),
                width: btnWidth,
                height: btnHeight,
              ),
              _CalcButton(
                label: '-',
                color: context.colorScheme.primary,
                onTap: () => _append('-'),
                width: btnWidth,
                height: btnHeight,
              ),
            ], gap: gap),
            const SizedBox(height: gap),
            _buildRow([
              _CalcButton(
                label: '1',
                color: context.colorScheme.surfaceContainerHighest,
                textColor: context.colorScheme.onSurface,
                onTap: () => _append('1'),
                width: btnWidth,
                height: btnHeight,
              ),
              _CalcButton(
                label: '2',
                color: context.colorScheme.surfaceContainerHighest,
                textColor: context.colorScheme.onSurface,
                onTap: () => _append('2'),
                width: btnWidth,
                height: btnHeight,
              ),
              _CalcButton(
                label: '3',
                color: context.colorScheme.surfaceContainerHighest,
                textColor: context.colorScheme.onSurface,
                onTap: () => _append('3'),
                width: btnWidth,
                height: btnHeight,
              ),
              _CalcButton(
                label: '+',
                color: context.colorScheme.primary,
                onTap: () => _append('+'),
                width: btnWidth,
                height: btnHeight,
              ),
            ], gap: gap),
            const SizedBox(height: gap),
            _buildRow([
              _CalcButton(
                label: '0',
                color: context.colorScheme.surfaceContainerHighest,
                textColor: context.colorScheme.onSurface,
                onTap: () => _append('0'),
                width: btnWidth,
                height: btnHeight,
              ),
              _CalcButton(
                label: '.',
                color: context.colorScheme.surfaceContainerHighest,
                textColor: context.colorScheme.onSurface,
                onTap: () => _append('.'),
                width: btnWidth,
                height: btnHeight,
              ),
              _CalcButton(
                label: '\u232B',
                color: context.colorScheme.surfaceContainerHighest,
                textColor: context.colorScheme.onSurfaceVariant,
                onTap: _backspace,
                onLongPress: _clear,
                width: btnWidth,
                height: btnHeight,
              ),
              _CalcButton(
                label: '=',
                color: context.colorScheme.primary,
                onTap: _calculate,
                width: btnWidth,
                height: btnHeight,
              ),
            ], gap: gap),
            const SizedBox(height: gap),
            _buildRow([
              _CalcButton(
                label: 'sin',
                color: context.colorScheme.secondaryContainer,
                textColor: context.colorScheme.onSecondaryContainer,
                onTap: () => _append('sin('),
                fontSize: 13,
                width: btnWidth,
                height: btnHeight,
              ),
              _CalcButton(
                label: 'cos',
                color: context.colorScheme.secondaryContainer,
                textColor: context.colorScheme.onSecondaryContainer,
                onTap: () => _append('cos('),
                fontSize: 13,
                width: btnWidth,
                height: btnHeight,
              ),
              _CalcButton(
                label: 'tan',
                color: context.colorScheme.secondaryContainer,
                textColor: context.colorScheme.onSecondaryContainer,
                onTap: () => _append('tan('),
                fontSize: 13,
                width: btnWidth,
                height: btnHeight,
              ),
              _CalcButton(
                label: '^',
                color: context.colorScheme.primary,
                onTap: () => _append('^'),
                width: btnWidth,
                height: btnHeight,
              ),
            ], gap: gap),
            const SizedBox(height: gap),
            _buildRow([
              _CalcButton(
                label: 'log',
                color: context.colorScheme.secondaryContainer,
                textColor: context.colorScheme.onSecondaryContainer,
                onTap: () => _append('log('),
                fontSize: 13,
                width: btnWidth,
                height: btnHeight,
              ),
              _CalcButton(
                label: 'ln',
                color: context.colorScheme.secondaryContainer,
                textColor: context.colorScheme.onSecondaryContainer,
                onTap: () => _append('ln('),
                fontSize: 13,
                width: btnWidth,
                height: btnHeight,
              ),
              _CalcButton(
                label: '\u221A',
                color: context.colorScheme.secondaryContainer,
                textColor: context.colorScheme.onSecondaryContainer,
                onTap: () => _append('sqrt('),
                fontSize: 18,
                width: btnWidth,
                height: btnHeight,
              ),
              _CalcButton(
                label: '\u03C0',
                color: context.colorScheme.secondaryContainer,
                textColor: context.colorScheme.onSecondaryContainer,
                onTap: () => _append('\u03C0'),
                fontSize: 18,
                width: btnWidth,
                height: btnHeight,
              ),
            ], gap: gap),
          ],
        );
      },
    );
  }

  Widget _buildRow(List<Widget> children, {required double gap}) {
    return IntrinsicHeight(
      child: Row(
        children: children
            .map((child) => Padding(
                  padding: EdgeInsets.only(right: children.last != child ? gap : 0),
                  child: child,
                ))
            .toList(),
      ),
    );
  }
}

class _CalcButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Color? color;
  final Color? textColor;
  final double width;
  final double height;
  final double fontSize;

  const _CalcButton({
    required this.label,
    required this.onTap,
    this.onLongPress,
    this.color,
    this.textColor,
    required this.width,
    required this.height,
    this.fontSize = 20,
  });

  @override
  State<_CalcButton> createState() => _CalcButtonState();
}

class _CalcButtonState extends State<_CalcButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.buttonPress,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: AppAnimations.buttonPressScale)
        .animate(CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.buttonPressCurve,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  void _onLongPressStart(LongPressStartDetails details) {
    _controller.forward();
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    _controller.reverse();
    widget.onLongPress?.call();
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.color ?? context.colorScheme.surfaceContainerHighest;
    final fg = widget.textColor ?? context.colorScheme.onPrimary;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onLongPressStart: widget.onLongPress != null ? _onLongPressStart : null,
        onLongPressEnd: widget.onLongPress != null ? _onLongPressEnd : null,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: widget.fontSize,
              fontWeight: FontWeight.w500,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }
}
