import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
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
              hintText: 'e.g., x^2, sin(x), exp(x)',
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          TextField(
            controller: _variableController,
            decoration: const InputDecoration(labelText: 'Variable'),
          ),
          const SizedBox(height: AppDimensions.md),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _lowerBoundController,
                  decoration: const InputDecoration(labelText: 'Lower bound (optional)'),
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: TextField(
                  controller: _upperBoundController,
                  decoration: const InputDecoration(labelText: 'Upper bound (optional)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _calculate,
              child: const Text('Integrate'),
            ),
          ),
          const SizedBox(height: AppDimensions.lg),
          BlocBuilder<IntegralBloc, IntegralState>(
            builder: (context, state) {
              if (state is IntegralLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is IntegralResultState) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Result', style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppDimensions.fontSizeLg)),
                        const SizedBox(height: AppDimensions.sm),
                        Text(
                          '\u222B ${state.result.function} d${state.result.variable} = ${state.result.result}',
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
              if (state is IntegralError) {
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
