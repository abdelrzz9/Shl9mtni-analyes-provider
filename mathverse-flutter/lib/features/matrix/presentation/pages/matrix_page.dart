import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../data/repositories/matrix_repository_impl.dart';
import '../../domain/usecases/matrix_operation.dart';
import '../bloc/matrix_bloc.dart';

class MatrixPage extends StatelessWidget {
  const MatrixPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Matrix Operations')),
      body: BlocProvider(
        create: (_) => MatrixBloc(
          matrixOperation: MatrixOperation(MatrixRepositoryImpl()),
        ),
        child: const _MatrixBody(),
      ),
    );
  }
}

class _MatrixBody extends StatefulWidget {
  const _MatrixBody();

  @override
  State<_MatrixBody> createState() => _MatrixBodyState();
}

class _MatrixBodyState extends State<_MatrixBody> {
  final _matrixAController = TextEditingController();
  final _matrixBController = TextEditingController();
  String _selectedOperation = 'add';

  final _operations = [
    'add', 'subtract', 'multiply', 'determinant', 'inverse', 'transpose',
  ];

  @override
  void dispose() {
    _matrixAController.dispose();
    _matrixBController.dispose();
    super.dispose();
  }

  bool get _needsTwoMatrices =>
      _selectedOperation == 'add' ||
      _selectedOperation == 'subtract' ||
      _selectedOperation == 'multiply';

  void _calculate() {
    if (_matrixAController.text.isEmpty) return;
    if (_needsTwoMatrices && _matrixBController.text.isEmpty) return;
    context.read<MatrixBloc>().add(PerformMatrixOperation(
      operation: _selectedOperation,
      matrixA: _matrixAController.text,
      matrixB: _needsTwoMatrices ? _matrixBController.text : null,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _selectedOperation,
            decoration: const InputDecoration(labelText: 'Operation'),
            items: _operations.map((op) {
              return DropdownMenuItem(
                value: op,
                child: Text(op[0].toUpperCase() + op.substring(1)),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedOperation = value!),
          ),
          const SizedBox(height: AppDimensions.md),
          TextField(
            controller: _matrixAController,
            decoration: const InputDecoration(
              labelText: 'Matrix A',
              hintText: 'e.g., 1,2;3,4',
              helperText: 'Rows separated by ;, columns by ,',
            ),
            maxLines: 3,
          ),
          if (_needsTwoMatrices) ...[
            const SizedBox(height: AppDimensions.md),
            TextField(
              controller: _matrixBController,
              decoration: const InputDecoration(
                labelText: 'Matrix B',
                hintText: 'e.g., 5,6;7,8',
                helperText: 'Rows separated by ;, columns by ,',
              ),
              maxLines: 3,
            ),
          ],
          const SizedBox(height: AppDimensions.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _calculate,
              child: Text(_selectedOperation[0].toUpperCase() + _selectedOperation.substring(1)),
            ),
          ),
          const SizedBox(height: AppDimensions.lg),
          BlocBuilder<MatrixBloc, MatrixState>(
            builder: (context, state) {
              if (state is MatrixLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is MatrixResultState) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Result', style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppDimensions.fontSizeLg)),
                        const SizedBox(height: AppDimensions.sm),
                        Text(
                          state.result.result,
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
              if (state is MatrixError) {
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
