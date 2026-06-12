import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
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
              hintText: 'e.g., sin(x), cos(x), exp(x)',
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
                child: TextField(
                  controller: _centerController,
                  decoration: const InputDecoration(labelText: 'Center'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          Column(
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
          const SizedBox(height: AppDimensions.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _calculate,
              child: const Text('Expand DL'),
            ),
          ),
          const SizedBox(height: AppDimensions.lg),
          BlocBuilder<DLBloc, DLState>(
            builder: (context, state) {
              if (state is DLLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is DLResultState) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Result', style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppDimensions.fontSizeLg)),
                        const SizedBox(height: AppDimensions.sm),
                        Text(
                          '${state.result.function} = ${state.result.result}',
                          style: const TextStyle(fontSize: AppDimensions.fontSizeXl, color: AppColors.primary),
                        ),
                        if (state.result.terms != null) ...[
                          const SizedBox(height: AppDimensions.md),
                          const Text('Terms', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: AppDimensions.xs),
                          Text(state.result.terms!),
                        ],
                      ],
                    ),
                  ),
                );
              }
              if (state is DLError) {
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
