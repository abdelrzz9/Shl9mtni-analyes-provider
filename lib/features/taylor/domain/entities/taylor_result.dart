import 'package:equatable/equatable.dart';

class TaylorResult extends Equatable {
  final String function;
  final String variable;
  final String center;
  final int order;
  final String result;
  final String? terms;
  final String? latexOutput;

  const TaylorResult({
    required this.function,
    required this.variable,
    required this.center,
    required this.order,
    required this.result,
    this.terms,
    this.latexOutput,
  });

  @override
  List<Object?> get props => [function, variable, center, order, result, terms, latexOutput];
}
