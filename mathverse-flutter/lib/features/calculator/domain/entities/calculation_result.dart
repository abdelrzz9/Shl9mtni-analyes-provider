import 'package:equatable/equatable.dart';

class CalculationResult extends Equatable {
  final String expression;
  final double result;
  final String? latexOutput;
  final DateTime timestamp;

  const CalculationResult({
    required this.expression,
    required this.result,
    this.latexOutput,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [expression, result, latexOutput, timestamp];

  CalculationResult copyWith({
    String? expression,
    double? result,
    String? latexOutput,
    DateTime? timestamp,
  }) {
    return CalculationResult(
      expression: expression ?? this.expression,
      result: result ?? this.result,
      latexOutput: latexOutput ?? this.latexOutput,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
