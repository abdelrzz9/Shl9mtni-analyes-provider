import 'package:equatable/equatable.dart';

class MatrixResult extends Equatable {
  final String operation;
  final String? matrixA;
  final String? matrixB;
  final String result;
  final String? steps;
  final String? latexOutput;

  const MatrixResult({
    required this.operation,
    this.matrixA,
    this.matrixB,
    required this.result,
    this.steps,
    this.latexOutput,
  });

  @override
  List<Object?> get props => [operation, matrixA, matrixB, result, steps, latexOutput];
}
