import 'package:equatable/equatable.dart';

class IntegralResult extends Equatable {
  final String function;
  final String variable;
  final String? lowerBound;
  final String? upperBound;
  final String result;
  final String? steps;
  final String? latexOutput;

  const IntegralResult({
    required this.function,
    required this.variable,
    this.lowerBound,
    this.upperBound,
    required this.result,
    this.steps,
    this.latexOutput,
  });

  @override
  List<Object?> get props => [function, variable, lowerBound, upperBound, result, steps, latexOutput];
}
