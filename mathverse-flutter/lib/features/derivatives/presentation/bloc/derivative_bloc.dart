import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/derivative_result.dart';
import '../../domain/usecases/differentiate_function.dart';

sealed class DerivativeEvent extends Equatable {
  const DerivativeEvent();

  @override
  List<Object?> get props => [];
}

final class Differentiate extends DerivativeEvent {
  final String function;
  final String variable;
  final int order;

  const Differentiate({
    required this.function,
    this.variable = 'x',
    this.order = 1,
  });

  @override
  List<Object?> get props => [function, variable, order];
}

final class ClearDerivative extends DerivativeEvent {
  const ClearDerivative();
}

sealed class DerivativeState extends Equatable {
  const DerivativeState();

  @override
  List<Object?> get props => [];
}

final class DerivativeInitial extends DerivativeState {
  const DerivativeInitial();
}

final class DerivativeLoading extends DerivativeState {
  const DerivativeLoading();
}

final class DerivativeResultState extends DerivativeState {
  final DerivativeResult result;

  const DerivativeResultState(this.result);

  @override
  List<Object?> get props => [result];
}

final class DerivativeError extends DerivativeState {
  final String message;

  const DerivativeError(this.message);

  @override
  List<Object?> get props => [message];
}

class DerivativeBloc extends Bloc<DerivativeEvent, DerivativeState> {
  final DifferentiateFunction _differentiateFunction;

  DerivativeBloc({required this._differentiateFunction})
      : super(const DerivativeInitial()) {
    on<Differentiate>(_onDifferentiate);
    on<ClearDerivative>(_onClear);
  }

  Future<void> _onDifferentiate(Differentiate event, Emitter<DerivativeState> emit) async {
    emit(const DerivativeLoading());
    try {
      final result = await _differentiateFunction(
        event.function,
        event.variable,
        order: event.order,
      );
      emit(DerivativeResultState(result));
    } catch (e) {
      emit(DerivativeError(e.toString()));
    }
  }

  void _onClear(ClearDerivative event, Emitter<DerivativeState> emit) {
    emit(const DerivativeInitial());
  }
}
