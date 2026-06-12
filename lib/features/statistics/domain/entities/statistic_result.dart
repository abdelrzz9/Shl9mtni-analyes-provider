import 'package:equatable/equatable.dart';

class StatisticResult extends Equatable {
  final String data;
  final String operation;
  final String result;
  final String? details;
  final String? latexOutput;

  const StatisticResult({
    required this.data,
    required this.operation,
    required this.result,
    this.details,
    this.latexOutput,
  });

  @override
  List<Object?> get props => [data, operation, result, details, latexOutput];
}
