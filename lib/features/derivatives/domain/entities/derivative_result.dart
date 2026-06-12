import 'package:equatable/equatable.dart';

class DerivativeResult extends Equatable {
  final String function;
  final String variable;
  final int order;
  final String result;
  final String? steps;
  final String? latexOutput;

  const DerivativeResult({
    required this.function,
    required this.variable,
    required this.order,
    required this.result,
    this.steps,
    this.latexOutput,
  });

  @override
  List<Object?> get props => [function, variable, order, result, steps, latexOutput];
}
