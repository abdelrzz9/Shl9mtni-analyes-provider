import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../data/repositories/statistic_repository_impl.dart';
import '../../domain/usecases/calculate_statistic.dart';
import '../bloc/statistic_bloc.dart';

class StatisticPage extends StatelessWidget {
  const StatisticPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: BlocProvider(
        create: (_) => StatisticBloc(
          calculateStatistic: CalculateStatistic(StatisticRepositoryImpl()),
        ),
        child: const _StatisticBody(),
      ),
    );
  }
}

class _StatisticBody extends StatefulWidget {
  const _StatisticBody();

  @override
  State<_StatisticBody> createState() => _StatisticBodyState();
}

class _StatisticBodyState extends State<_StatisticBody> {
  final _dataController = TextEditingController();
  final _data2Controller = TextEditingController();
  String _selectedOperation = 'mean';

  final _operations = [
    'mean', 'median', 'mode', 'stdDev', 'variance', 'correlation',
  ];

  @override
  void dispose() {
    _dataController.dispose();
    _data2Controller.dispose();
    super.dispose();
  }

  bool get _needsTwoDataSets => _selectedOperation == 'correlation';

  List<double> _parseData(String input) {
    return input.split(',')
        .map((e) => double.tryParse(e.trim()))
        .where((e) => e != null)
        .cast<double>()
        .toList();
  }

  void _calculate() {
    final data = _parseData(_dataController.text);
    if (data.isEmpty) return;
    List<double>? data2;
    if (_needsTwoDataSets) {
      data2 = _parseData(_data2Controller.text);
      if (data2.isEmpty) return;
    }
    context.read<StatisticBloc>().add(Calculate(
      operation: _selectedOperation,
      data: data,
      data2: data2,
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
            value: _selectedOperation,
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
            controller: _dataController,
            decoration: const InputDecoration(
              labelText: 'Data set',
              hintText: 'e.g., 1, 2, 3, 4, 5',
              helperText: 'Comma-separated numbers',
            ),
          ),
          if (_needsTwoDataSets) ...[
            const SizedBox(height: AppDimensions.md),
            TextField(
              controller: _data2Controller,
              decoration: const InputDecoration(
                labelText: 'Second data set',
                hintText: 'e.g., 2, 4, 6, 8, 10',
                helperText: 'Comma-separated numbers',
              ),
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
          BlocBuilder<StatisticBloc, StatisticState>(
            builder: (context, state) {
              if (state is StatisticLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is StatisticResultState) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Result', style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppDimensions.fontSizeLg)),
                        const SizedBox(height: AppDimensions.sm),
                        Text(
                          '${state.result.operation}: ${state.result.result}',
                          style: const TextStyle(fontSize: AppDimensions.fontSizeXl, color: AppColors.primary),
                        ),
                        if (state.result.details != null) ...[
                          const SizedBox(height: AppDimensions.md),
                          const Text('Details', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: AppDimensions.xs),
                          Text(state.result.details!),
                        ],
                      ],
                    ),
                  ),
                );
              }
              if (state is StatisticError) {
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
