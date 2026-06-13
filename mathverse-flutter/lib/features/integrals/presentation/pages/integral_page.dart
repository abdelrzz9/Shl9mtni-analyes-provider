import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/loading_widgets.dart';
import '../../../../core/widgets/mathverse_button.dart';
import '../../../../core/widgets/mathverse_card.dart';
import '../../../../core/widgets/mathverse_input.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../data/repositories/integral_repository_impl.dart';
import '../../domain/usecases/integrate_function.dart';
import '../bloc/integral_bloc.dart';

class IntegralPage extends StatelessWidget {
  const IntegralPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Integrals')),
      body: BlocProvider(
        create: (_) => IntegralBloc(
          integrateFunction: IntegrateFunction(IntegralRepositoryImpl()),
        ),
        child: const _IntegralBody(),
      ),
    );
  }
}

class _IntegralBody extends StatefulWidget {
  const _IntegralBody();

  @override
  State<_IntegralBody> createState() => _IntegralBodyState();
}

class _IntegralBodyState extends State<_IntegralBody> {
  final _functionController = TextEditingController();
  final _variableController = TextEditingController(text: 'x');
  final _lowerBoundController = TextEditingController();
  final _upperBoundController = TextEditingController();

  static const _examples = ['x^2', 'sin(x)', 'cos(x)', '1/x', 'exp(x)'];

  @override
  void dispose() {
    _functionController.dispose();
    _variableController.dispose();
    _lowerBoundController.dispose();
    _upperBoundController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (_functionController.text.isEmpty) return;
    context.read<IntegralBloc>().add(Integrate(
      function: _functionController.text,
      variable: _variableController.text.isEmpty ? 'x' : _variableController.text,
      lowerBound: _lowerBoundController.text.isEmpty ? null : _lowerBoundController.text,
      upperBound: _upperBoundController.text.isEmpty ? null : _upperBoundController.text,
    ));
  }

  void _onExampleTap(String example) {
    _functionController.text = example;
    _functionController.selection = TextSelection.fromPosition(
      TextPosition(offset: example.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = context.isDarkMode;

    return BlocBuilder<IntegralBloc, IntegralState>(
      builder: (context, state) {
        final isLoading = state is IntegralLoading;
        final result = state is IntegralResultState ? state.result : null;
        final error = state is IntegralError ? state.message : null;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: AppSpacing.contentMaxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInputCard(theme, isDark),
                  const SizedBox(height: AppSpacing.lg),
                  _buildExamplesSection(theme),
                  const SizedBox(height: AppSpacing.xl),
                  _buildSolveButton(theme),
                  const SizedBox(height: AppSpacing.xxl),
                  if (isLoading)
                    _buildLoadingState()
                  else if (error != null)
                    _buildErrorState(error)
                  else if (result != null)
                    _buildResultSection(result, theme, isDark)
                  else
                    const SizedBox.shrink(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputCard(ThemeData theme, bool isDark) {
    return MathVerseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.functions_rounded,
                  size: AppSizes.iconMedium,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Integral Calculator',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          MathVerseInput(
            controller: _functionController,
            labelText: 'f(x)',
            hintText: 'x^2, sin(x), exp(x)',
            prefixIcon: Icon(
              Icons.functions_rounded,
              size: AppSizes.iconMedium,
              color: theme.colorScheme.primary,
            ),
            onSubmitted: (_) => _calculate(),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: MathVerseInput(
                  controller: _variableController,
                  labelText: 'Variable',
                  hintText: 'x',
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: MathVerseInput(
                  controller: _lowerBoundController,
                  labelText: 'Lower bound',
                  hintText: 'Optional',
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: MathVerseInput(
                  controller: _upperBoundController,
                  labelText: 'Upper bound',
                  hintText: 'Optional',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExamplesSection(ThemeData theme) {
    return MathVerseCard(
      child: ExamplesSection(
        examples: _examples,
        onTap: _onExampleTap,
      ),
    );
  }

  Widget _buildSolveButton(ThemeData theme) {
    return MathVerseButton(
      label: 'Solve Integral',
      icon: Icons.calculate_rounded,
      onPressed: _calculate,
    );
  }

  Widget _buildLoadingState() {
    return const PageSkeleton(itemCount: 3);
  }

  Widget _buildErrorState(String message) {
    return ErrorState(
      icon: Icons.error_outline_rounded,
      title: 'Unable to compute integral',
      message: message,
      onRetry: _calculate,
    );
  }

  Widget _buildResultSection(
    dynamic result,
    ThemeData theme,
    bool isDark,
  ) {
    final expression = _buildIntegralExpression(result);
    final stepsList = _parseSteps(result.steps);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGradientResultCard(theme, isDark, expression, result.result),
        if (stepsList != null && stepsList.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          StepByStepCard(
            title: 'Step-by-Step Solution',
            steps: stepsList,
          ),
        ],
      ],
    );
  }

  String _buildIntegralExpression(dynamic result) {
    final hasBounds = result.lowerBound != null && result.upperBound != null;
    if (hasBounds) {
      return '\u222B_{${result.lowerBound}}^{${result.upperBound}} ${result.function} d${result.variable}';
    }
    return '\u222B ${result.function} d${result.variable}';
  }

  List<String>? _parseSteps(String? steps) {
    if (steps == null || steps.trim().isEmpty) return null;
    return steps
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  Widget _buildGradientResultCard(
    ThemeData theme,
    bool isDark,
    String expression,
    String resultText,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPaddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.darkPrimaryContainer,
                  AppColors.darkSecondaryContainer.withValues(alpha: 0.4),
                ]
              : [
                  AppColors.primaryContainer,
                  AppColors.secondaryContainer.withValues(alpha: 0.3),
                ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  size: AppSizes.iconMedium,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Result',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const Spacer(),
              _ActionButton(
                icon: Icons.copy_rounded,
                tooltip: 'Copy result',
                onTap: () {
                  Clipboard.setData(ClipboardData(text: resultText));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Result copied'),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              _ActionButton(
                icon: Icons.share_rounded,
                tooltip: 'Share',
                onTap: () {},
              ),
              _ActionButton(
                icon: Icons.bookmark_border_rounded,
                tooltip: 'Save',
                onTap: () {},
              ),
              _ActionButton(
                icon: Icons.star_border_rounded,
                tooltip: 'Add to favorites',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expression,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                SelectableText(
                  '= $resultText',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                    fontFamily: 'monospace',
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

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Icon(
              icon,
              size: AppSizes.iconMedium,
              color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }
}
