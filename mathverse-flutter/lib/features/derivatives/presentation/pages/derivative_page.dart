import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/loading_widgets.dart';
import '../../../../core/widgets/math_result_display.dart';
import '../../../../core/widgets/mathverse_card.dart';
import '../../../../core/widgets/mathverse_input.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../data/repositories/derivative_repository_impl.dart';
import '../../domain/usecases/differentiate_function.dart';
import '../bloc/derivative_bloc.dart';

class DerivativePage extends StatelessWidget {
  const DerivativePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Derivatives')),
      body: BlocProvider(
        create: (_) => DerivativeBloc(
          differentiateFunction: DifferentiateFunction(DerivativeRepositoryImpl()),
        ),
        child: const _DerivativeBody(),
      ),
    );
  }
}

class _DerivativeBody extends StatefulWidget {
  const _DerivativeBody();

  @override
  State<_DerivativeBody> createState() => _DerivativeBodyState();
}

class _DerivativeBodyState extends State<_DerivativeBody> {
  final _functionController = TextEditingController();
  final _variableController = TextEditingController(text: 'x');
  int _order = 1;

  @override
  void dispose() {
    _functionController.dispose();
    _variableController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (_functionController.text.isEmpty) return;
    context.read<DerivativeBloc>().add(Differentiate(
      function: _functionController.text,
      variable: _variableController.text.isEmpty ? 'x' : _variableController.text,
      order: _order,
    ));
  }

  void _incrementOrder() {
    setState(() => _order++);
  }

  void _decrementOrder() {
    if (_order > 1) {
      setState(() => _order--);
    }
  }

  void _onExampleTap(String example) {
    _functionController.text = example;
    _functionController.selection = TextSelection.fromPosition(
      TextPosition(offset: example.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DerivativeBloc, DerivativeState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: context.screenPadding,
          child: Center(
            child: SizedBox(
              width: context.maxContentWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInputCard(),
                  const SizedBox(height: AppSpacing.md),
                  _buildVariableOrderRow(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildExamples(),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildSolveButton(),
                  if (state is DerivativeLoading)
                    _buildLoading(),
                  if (state is DerivativeResultState)
                    _buildResult(state),
                  if (state is DerivativeError)
                    _buildError(state),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputCard() {
    return MathVerseCard(
      child: MathVerseInput(
        controller: _functionController,
        labelText: 'f(x)',
        hintText: 'x^2, sin(x), exp(x)',
        prefixIcon: const Icon(Icons.functions_rounded),
        textInputAction: TextInputAction.next,
        onSubmitted: (_) => _calculate(),
      ),
    );
  }

  Widget _buildVariableOrderRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: MathVerseInput(
            controller: _variableController,
            labelText: 'Variable',
            hintText: 'x',
            prefixIcon: const Icon(Icons.abc_rounded),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _calculate(),
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          flex: 3,
          child: _buildOrderStepper(),
        ),
      ],
    );
  }

  Widget _buildOrderStepper() {
    final theme = Theme.of(context);
    return MathVerseCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Order',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: _decrementOrder,
                icon: const Icon(Icons.remove_rounded),
                iconSize: AppSizes.iconMedium,
                splashRadius: 20,
                visualDensity: VisualDensity.compact,
                tooltip: 'Decrease order',
              ),
              Container(
                width: 32,
                alignment: Alignment.center,
                child: Text(
                  '$_order',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: _incrementOrder,
                icon: const Icon(Icons.add_rounded),
                iconSize: AppSizes.iconMedium,
                splashRadius: 20,
                visualDensity: VisualDensity.compact,
                tooltip: 'Increase order',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExamples() {
    return ExamplesSection(
      examples: const ['x^2', 'sin(x)', 'cos(x)', 'exp(x)', 'ln(x)'],
      onTap: _onExampleTap,
    );
  }

  Widget _buildSolveButton() {
    final theme = Theme.of(context);
    return Container(
      height: AppSizes.buttonHeight,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
        ),
        borderRadius: BorderRadius.circular(AppRadius.button),
        boxShadow: [
          BoxShadow(
            color: AppColors.gradientStart.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _calculate,
          borderRadius: BorderRadius.circular(AppRadius.button),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calculate_rounded, color: Colors.white, size: AppSizes.iconMedium),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Solve',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Padding(
      padding: EdgeInsets.only(top: AppSpacing.xxl),
      child: PageSkeleton(itemCount: 3),
    );
  }

  Widget _buildResult(DerivativeResultState state) {
    final result = state.result;
    final steps = result.steps?.split('\n').where((s) => s.trim().isNotEmpty).toList();

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xxl),
      child: MathResultDisplay(
        expression: 'f(${result.variable}) = ${result.function}',
        result: "f'(${result.variable}) = ${result.result}",
        steps: steps,
        onCopy: () => Clipboard.setData(ClipboardData(text: result.result)),
        onShare: () {},
        onSave: () {},
        onFavorite: () {},
      ),
    );
  }

  Widget _buildError(DerivativeError state) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xxl),
      child: ErrorState(
        message: state.message,
        onRetry: _calculate,
      ),
    );
  }
}
