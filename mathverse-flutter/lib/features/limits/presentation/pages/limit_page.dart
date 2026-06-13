import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/responsive.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/mathverse_card.dart';
import '../../../../core/widgets/mathverse_button.dart';
import '../../../../core/widgets/mathverse_input.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../../../core/widgets/loading_widgets.dart';
import '../../../../core/widgets/math_result_display.dart';
import '../../data/repositories/limit_repository_impl.dart';
import '../../domain/usecases/evaluate_limit.dart';
import '../bloc/limit_bloc.dart';

class LimitPage extends StatelessWidget {
  const LimitPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Limits')),
      body: BlocProvider(
        create: (_) => LimitBloc(
          evaluateLimit: EvaluateLimit(LimitRepositoryImpl()),
        ),
        child: const _LimitBody(),
      ),
    );
  }
}

class _LimitBody extends StatefulWidget {
  const _LimitBody();

  @override
  State<_LimitBody> createState() => _LimitBodyState();
}

class _LimitBodyState extends State<_LimitBody> {
  final _functionController = TextEditingController();
  final _variableController = TextEditingController(text: 'x');
  final _approachController = TextEditingController();
  String? _direction;

  static const _examples = [
    'sin(x)/x',
    '(1+x)^(1/x)',
    '1/x',
    '(e^x-1)/x',
  ];

  @override
  void dispose() {
    _functionController.dispose();
    _variableController.dispose();
    _approachController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (_functionController.text.isEmpty || _approachController.text.isEmpty) return;
    context.read<LimitBloc>().add(Evaluate(
      function: _functionController.text,
      variable: _variableController.text.isEmpty ? 'x' : _variableController.text,
      approachPoint: _approachController.text,
      direction: _direction,
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
    final padding = context.screenPadding;
    return BlocBuilder<LimitBloc, LimitState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: padding,
          child: Center(
            child: SizedBox(
              width: context.maxContentWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  SizedBox(height: AppSpacing.xxl),
                  _buildForm(context),
                  if (state is LimitInitial) ...[
                    SizedBox(height: AppSpacing.xxl),
                    _buildExamples(context),
                  ],
                  if (state is LimitLoading) ...[
                    SizedBox(height: AppSpacing.xxl),
                    _buildLoading(),
                  ],
                  if (state is LimitResultState) ...[
                    SizedBox(height: AppSpacing.xxl),
                    _buildResult(context, state),
                  ],
                  if (state is LimitError) ...[
                    SizedBox(height: AppSpacing.xxl),
                    _buildError(state),
                  ],
                  SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Limit Calculator',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          'Compute the limit of any function as it approaches a point',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context) {
    final theme = Theme.of(context);
    return MathVerseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter your function',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          MathVerseInput(
            controller: _functionController,
            labelText: 'Function f(x)',
            hintText: 'e.g., x^2, sin(x)/x, 1/x',
            prefixIcon: Icon(Icons.functions),
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: MathVerseInput(
                  controller: _variableController,
                  labelText: 'Variable',
                  prefixIcon: Icon(Icons.text_fields),
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 2,
                child: MathVerseInput(
                  controller: _approachController,
                  labelText: 'Approach point',
                  hintText: 'e.g., 0, inf, 1',
                  prefixIcon: Icon(Icons.my_location),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String?>(
            value: _direction,
            decoration: InputDecoration(
              labelText: 'Direction (optional)',
              filled: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppSpacing.inputHorizontal,
                vertical: AppSpacing.inputVertical,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.input),
                borderSide: BorderSide(color: theme.colorScheme.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.input),
                borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.input),
                borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
              ),
              fillColor: theme.colorScheme.surface,
            ),
            items: const [
              DropdownMenuItem<String?>(
                value: null,
                child: Text('Both sides'),
              ),
              DropdownMenuItem<String?>(
                value: 'right',
                child: Text('Right (+)'),
              ),
              DropdownMenuItem<String?>(
                value: 'left',
                child: Text('Left (-)'),
              ),
            ],
            onChanged: (value) => setState(() => _direction = value),
          ),
          SizedBox(height: AppSpacing.lg),
          MathVerseButton(
            label: 'Evaluate Limit',
            icon: Icons.calculate,
            onPressed: _calculate,
          ),
        ],
      ),
    );
  }

  Widget _buildExamples(BuildContext context) {
    return ExamplesSection(
      examples: _examples,
      onTap: _onExampleTap,
    );
  }

  Widget _buildLoading() {
    return Column(
      children: [
        SkeletonCard(height: 160),
        SizedBox(height: AppSpacing.md),
        SkeletonCard(height: 200),
      ],
    );
  }

  Widget _buildResult(BuildContext context, LimitResultState state) {
    final r = state.result;
    final expression = 'lim_{${r.variable}\u2192${r.approachPoint}} ${r.function}';
    final fullResult = '$expression = ${r.result}';
    return MathResultDisplay(
      expression: expression,
      result: '= ${r.result}',
      steps: r.steps?.split('\n').where((s) => s.trim().isNotEmpty).toList(),
      onCopy: () {
        Clipboard.setData(ClipboardData(text: fullResult));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Result copied to clipboard')),
        );
      },
      onShare: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Share coming soon')),
        );
      },
      onSave: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Result saved')),
        );
      },
      onFavorite: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to favorites')),
        );
      },
      isFavorite: false,
    );
  }

  Widget _buildError(LimitError state) {
    return ErrorState(
      title: 'Unable to compute limit',
      message: state.message,
      onRetry: _calculate,
      icon: Icons.calculate,
    );
  }
}
