import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/matrix_result.dart';
import '../../domain/usecases/matrix_operation.dart';

sealed class MatrixEvent extends Equatable {
  const MatrixEvent();

  @override
  List<Object?> get props => [];
}

final class PerformMatrixOperation extends MatrixEvent {
  final String operation;
  final String matrixA;
  final String? matrixB;

  const PerformMatrixOperation({
    required this.operation,
    required this.matrixA,
    this.matrixB,
  });

  @override
  List<Object?> get props => [operation, matrixA, matrixB];
}

final class ClearMatrix extends MatrixEvent {
  const ClearMatrix();
}

sealed class MatrixState extends Equatable {
  const MatrixState();

  @override
  List<Object?> get props => [];
}

final class MatrixInitial extends MatrixState {
  const MatrixInitial();
}

final class MatrixLoading extends MatrixState {
  const MatrixLoading();
}

final class MatrixResultState extends MatrixState {
  final MatrixResult result;

  const MatrixResultState(this.result);

  @override
  List<Object?> get props => [result];
}

final class MatrixError extends MatrixState {
  final String message;

  const MatrixError(this.message);

  @override
  List<Object?> get props => [message];
}

class MatrixBloc extends Bloc<MatrixEvent, MatrixState> {
  final MatrixOperation _matrixOperation;

  MatrixBloc({required this._matrixOperation})
      : super(const MatrixInitial()) {
    on<PerformMatrixOperation>(_onPerformOperation);
    on<ClearMatrix>(_onClear);
  }

  Future<void> _onPerformOperation(PerformMatrixOperation event, Emitter<MatrixState> emit) async {
    emit(const MatrixLoading());
    try {
      final result = await _matrixOperation(
        operation: event.operation,
        matrixA: event.matrixA,
        matrixB: event.matrixB,
      );
      emit(MatrixResultState(result));
    } catch (e) {
      emit(MatrixError(e.toString()));
    }
  }

  void _onClear(ClearMatrix event, Emitter<MatrixState> emit) {
    emit(const MatrixInitial());
  }
}
