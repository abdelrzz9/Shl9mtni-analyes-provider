import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _functionController,
            decoration: const InputDecoration(
              labelText: 'Function f(x)',
              hintText: 'e.g., x^2, sin(x)/x, 1/x',
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          TextField(
            controller: _variableController,
            decoration: const InputDecoration(labelText: 'Variable'),
          ),
          const SizedBox(height: AppDimensions.md),
          TextField(
            controller: _approachController,
            decoration: const InputDecoration(
              labelText: 'Approach point',
              hintText: 'e.g., 0, inf, 1',
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          DropdownButtonFormField<String>(
            value: _direction,
            decoration: const InputDecoration(labelText: 'Direction (optional)'),
            items: const [
              DropdownMenuItem(child: Text('Both sides')),
              DropdownMenuItem(value: 'right', child: Text('Right (+)')),
              DropdownMenuItem(value: 'left', child: Text('Left (-)')),
            ],
            onChanged: (value) => setState(() => _direction = value),
          ),
          const SizedBox(height: AppDimensions.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _calculate,
              child: const Text('Evaluate Limit'),
            ),
          ),
          const SizedBox(height: AppDimensions.lg),
          BlocBuilder<LimitBloc, LimitState>(
            builder: (context, state) {
              if (state is LimitLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is LimitResultState) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Result', style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppDimensions.fontSizeLg)),
                        const SizedBox(height: AppDimensions.sm),
                        Text(
                          'lim_{${state.result.variable} \u2192 ${state.result.approachPoint}} ${state.result.function} = ${state.result.result}',
                          style: const TextStyle(fontSize: AppDimensions.fontSizeXl, color: AppColors.primary),
                        ),
                        if (state.result.steps != null) ...[
                          const SizedBox(height: AppDimensions.md),
                          const Text('Steps', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: AppDimensions.xs),
                          Text(state.result.steps!),
                        ],
                      ],
                    ),
                  ),
                );
              }
              if (state is LimitError) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.md),
                    child: Text(state.message, style: const TextStyle(color: AppColors.error)),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
