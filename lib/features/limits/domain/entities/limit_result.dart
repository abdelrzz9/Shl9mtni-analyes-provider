import 'package:equatable/equatable.dart';

class LimitResult extends Equatable {
  final String function;
  final String variable;
  final String approachPoint;
  final String? direction;
  final String result;
  final String? steps;
  final String? latexOutput;

  const LimitResult({
    required this.function,
    required this.variable,
    required this.approachPoint,
    this.direction,
    required this.result,
    this.steps,
    this.latexOutput,
  });

  @override
  List<Object?> get props => [function, variable, approachPoint, direction, result, steps, latexOutput];
}
