import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
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
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _variableController,
                  decoration: const InputDecoration(labelText: 'Variable'),
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Order'),
                    const SizedBox(height: AppDimensions.xs),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () => setState(() => _order = (_order > 1) ? _order - 1 : 1),
                        ),
                        Text('$_order', style: const TextStyle(fontSize: AppDimensions.fontSizeLg)),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => setState(() => _order = _order + 1),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _calculate,
              child: const Text('Differentiate'),
            ),
          ),
          const SizedBox(height: AppDimensions.lg),
          BlocBuilder<DerivativeBloc, DerivativeState>(
            builder: (context, state) {
              if (state is DerivativeLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is DerivativeResultState) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Result', style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppDimensions.fontSizeLg)),
                        const SizedBox(height: AppDimensions.sm),
                        Text(
                          "f'(${state.result.variable}) = ${state.result.result}",
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
              if (state is DerivativeError) {
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
