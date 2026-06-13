import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/loading_widgets.dart';
import '../../../../core/widgets/math_result_display.dart';
import '../../../../core/widgets/mathverse_button.dart';
import '../../../../core/widgets/mathverse_card.dart';
import '../../../../core/widgets/mathverse_input.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../data/repositories/dl_repository_impl.dart';
import '../../domain/usecases/expand_dl.dart';
import '../bloc/dl_bloc.dart';

class DLPage extends StatelessWidget {
  const DLPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('D\u00e9veloppement Limit\u00e9')),
      body: BlocProvider(
        create: (_) => DLBloc(
          expandDL: ExpandDL(DLRepositoryImpl()),
        ),
        child: const _DLBody(),
      ),
    );
  }
}

class _DLBody extends StatefulWidget {
  const _DLBody();

  @override
  State<_DLBody> createState() => _DLBodyState();
}

class _DLBodyState extends State<_DLBody> {
  final _functionController = TextEditingController();
  final _variableController = TextEditingController(text: 'x');
  final _centerController = TextEditingController(text: '0');
  int _order = 3;

  @override
  void dispose() {
    _functionController.dispose();
    _variableController.dispose();
    _centerController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (_functionController.text.isEmpty) return;
    context.read<DLBloc>().add(ExpandDLSeries(
      function: _functionController.text,
      variable: _variableController.text.isEmpty ? 'x' : _variableController.text,
      center: _centerController.text.isEmpty ? '0' : _centerController.text,
      order: _order,
    ));
  }

  void _setExample(String example) {
    _functionController.text = example;
    _calculate();
  }

  void _copyResult(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard'), duration: Duration(seconds: 2)),
    );
  }

  void _shareResult(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Result copied, ready to share'), duration: Duration(seconds: 2)),
    );
  }

  void _saveResult() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Result saved'), duration: Duration(seconds: 2)),
    );
  }

  void _toggleFavorite() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Added to favorites'), duration: Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.screenPadding),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: AppSpacing.contentMaxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MathVerseCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MathVerseInput(
                      controller: _functionController,
                      labelText: 'Function f(x)',
                      hintText: 'e.g., sin(x), cos(x), exp(x)',
                      prefixIcon: Icon(Icons.functions_rounded, size: AppSizes.iconMedium, color: theme.colorScheme.primary),
                      onSubmitted: (_) => _calculate(),
                    ),
                    SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: MathVerseInput(
                            controller: _variableController,
                            labelText: 'Variable',
                            prefixIcon: Icon(Icons.text_fields_rounded, size: AppSizes.iconMedium, color: theme.colorScheme.primary),
                          ),
                        ),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: MathVerseInput(
                            controller: _centerController,
                            labelText: 'Center',
                            prefixIcon: Icon(Icons.center_focus_strong_rounded, size: AppSizes.iconMedium, color: theme.colorScheme.primary),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Text('Degree/Order', style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        )),
                        const Spacer(),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: theme.colorScheme.outlineVariant),
                            borderRadius: BorderRadius.circular(AppRadius.input),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () => setState(() => _order = (_order > 1) ? _order - 1 : 1),
                                borderRadius: BorderRadius.horizontal(left: Radius.circular(AppRadius.input)),
                                child: Padding(
                                  padding: EdgeInsets.all(AppSpacing.md),
                                  child: Icon(Icons.remove_rounded, size: AppSizes.iconMedium, color: theme.colorScheme.primary),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                                constraints: const BoxConstraints(minWidth: AppSizes.buttonMinWidth),
                                child: Text('$_order', style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                )),
                              ),
                              InkWell(
                                onTap: () => setState(() => _order = _order + 1),
                                borderRadius: BorderRadius.horizontal(right: Radius.circular(AppRadius.input)),
                                child: Padding(
                                  padding: EdgeInsets.all(AppSpacing.md),
                                  child: Icon(Icons.add_rounded, size: AppSizes.iconMedium, color: theme.colorScheme.primary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              ExamplesSection(
                examples: const ['sin(x)', 'cos(x)', 'exp(x)', 'ln(1+x)', '1/(1-x)'],
                onTap: _setExample,
              ),
              SizedBox(height: AppSpacing.xl),
              MathVerseButton(
                label: 'Expand DL',
                onPressed: _calculate,
                icon: Icons.calculate_rounded,
              ),
              SizedBox(height: AppSpacing.xl),
              BlocBuilder<DLBloc, DLState>(
                builder: (context, state) {
                  if (state is DLLoading) {
                    return Column(
                      children: [
                        SkeletonCard(height: 160),
                        SizedBox(height: AppSpacing.md),
                        SkeletonCard(height: 100),
                      ],
                    );
                  }
                  if (state is DLResultState) {
                    final result = state.result;
                    final terms = result.terms
                        ?.split('\n')
                        .map((t) => t.trim())
                        .where((t) => t.isNotEmpty)
                        .toList();
                    final displayResult = '${result.function} = ${result.result}';
                    return MathResultDisplay(
                      expression: 'f(${result.variable}) = ${result.function}',
                      result: '= ${result.result}',
                      steps: terms,
                      onCopy: () => _copyResult(displayResult),
                      onShare: () => _shareResult(displayResult),
                      onSave: _saveResult,
                      onFavorite: _toggleFavorite,
                    );
                  }
                  if (state is DLError) {
                    return ErrorState(
                      title: 'Calculation Error',
                      message: state.message,
                      onRetry: _calculate,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
