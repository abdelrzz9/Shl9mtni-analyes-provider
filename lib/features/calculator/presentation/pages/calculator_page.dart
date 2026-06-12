import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../data/repositories/calculator_repository_impl.dart';
import '../../domain/usecases/evaluate_expression.dart';
import '../bloc/calculator_bloc.dart';
import '../widgets/calculator_button.dart';

class CalculatorPage extends StatelessWidget {
  const CalculatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calculator')),
      body: BlocProvider(
        create: (_) => CalculatorBloc(
          evaluateExpression: EvaluateExpression(CalculatorRepositoryImpl()),
        ),
        child: const _CalculatorBody(),
      ),
    );
  }
}

class _CalculatorBody extends StatefulWidget {
  const _CalculatorBody();

  @override
  State<_CalculatorBody> createState() => _CalculatorBodyState();
}

class _CalculatorBodyState extends State<_CalculatorBody> {
  String _currentExpression = '';
  final _expressionController = TextEditingController();

  void _append(String value) {
    setState(() {
      _currentExpression += value;
      _expressionController.text = _currentExpression;
      _expressionController.selection = TextSelection.fromPosition(
        TextPosition(offset: _expressionController.text.length),
      );
    });
  }

  void _clear() {
    setState(() {
      _currentExpression = '';
      _expressionController.text = '';
    });
  }

  void _backspace() {
    if (_currentExpression.isNotEmpty) {
      setState(() {
        _currentExpression = _currentExpression.substring(0, _currentExpression.length - 1);
        _expressionController.text = _currentExpression;
      });
    }
  }

  void _calculate() {
    if (_currentExpression.isEmpty) return;
    context.read<CalculatorBloc>().add(Calculate(_currentExpression));
  }

  @override
  void dispose() {
    _expressionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: BlocBuilder<CalculatorBloc, CalculatorState>(
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.all(AppDimensions.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextField(
                      controller: _expressionController,
                      decoration: const InputDecoration(
                        hintText: 'Enter expression',
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(
                        fontSize: AppDimensions.fontSizeXl,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.right,
                      onChanged: (value) {
                        _currentExpression = value;
                      },
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    if (state is CalculatorResultState)
                      Text(
                        '= ${state.result.result.toStringAsFixed(6)}',
                        style: const TextStyle(
                          fontSize: AppDimensions.fontSizeXxl,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      )
                    else if (state is CalculatorError)
                      Text(
                        state.message,
                        style: const TextStyle(
                          fontSize: AppDimensions.fontSizeMd,
                          color: AppColors.error,
                        ),
                      ),
                    if (state is CalculatorLoading)
                      const Padding(
                        padding: EdgeInsets.all(AppDimensions.sm),
                        child: CircularProgressIndicator(),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        _buildButtonGrid(),
      ],
    );
  }

  Widget _buildButtonGrid() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.sm),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.cardRadius)),
      ),
      child: Column(
        children: [
          Row(children: [
            _buildButton('C', AppColors.error, _clear),
            _buildButton('(', AppColors.secondary, () => _append('(')),
            _buildButton(')', AppColors.secondary, () => _append(')')),
            _buildButton('÷', AppColors.accent, () => _append('/')),
          ]),
          const SizedBox(height: AppDimensions.xs),
          Row(children: [
            _buildButton('7', null, () => _append('7')),
            _buildButton('8', null, () => _append('8')),
            _buildButton('9', null, () => _append('9')),
            _buildButton('×', AppColors.accent, () => _append('*')),
          ]),
          const SizedBox(height: AppDimensions.xs),
          Row(children: [
            _buildButton('4', null, () => _append('4')),
            _buildButton('5', null, () => _append('5')),
            _buildButton('6', null, () => _append('6')),
            _buildButton('-', AppColors.accent, () => _append('-')),
          ]),
          const SizedBox(height: AppDimensions.xs),
          Row(children: [
            _buildButton('1', null, () => _append('1')),
            _buildButton('2', null, () => _append('2')),
            _buildButton('3', null, () => _append('3')),
            _buildButton('+', AppColors.accent, () => _append('+')),
          ]),
          const SizedBox(height: AppDimensions.xs),
          Row(children: [
            _buildButton('0', null, () => _append('0')),
            _buildButton('.', null, () => _append('.')),
            CalculatorButton(label: '⌫', backgroundColor: AppColors.warning, onTap: _backspace),
            CalculatorButton(label: '=', backgroundColor: AppColors.success, onTap: _calculate),
          ]),
          const SizedBox(height: AppDimensions.xs),
          Row(children: [
            _buildButton('sin', AppColors.secondary, () => _append('sin(')),
            _buildButton('cos', AppColors.secondary, () => _append('cos(')),
            _buildButton('tan', AppColors.secondary, () => _append('tan(')),
            _buildButton('^', AppColors.secondary, () => _append('^')),
          ]),
          const SizedBox(height: AppDimensions.xs),
          Row(children: [
            _buildButton('log', AppColors.secondary, () => _append('log(')),
            _buildButton('ln', AppColors.secondary, () => _append('ln(')),
            _buildButton('√', AppColors.secondary, () => _append('sqrt(')),
            _buildButton('π', AppColors.secondary, () => _append('π')),
          ]),
        ],
      ),
    );
  }

  Widget _buildButton(String label, Color? color, VoidCallback onTap) {
    return CalculatorButton(
      label: label,
      backgroundColor: color ?? AppColors.primary,
      onTap: onTap,
    );
  }
}
