import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/limit_result.dart';
import '../../domain/usecases/evaluate_limit.dart';

sealed class LimitEvent extends Equatable {
  const LimitEvent();

  @override
  List<Object?> get props => [];
}

final class Evaluate extends LimitEvent {
  final String function;
  final String variable;
  final String approachPoint;
  final String? direction;

  const Evaluate({
    required this.function,
    this.variable = 'x',
    required this.approachPoint,
    this.direction,
  });

  @override
  List<Object?> get props => [function, variable, approachPoint, direction];
}

final class ClearLimit extends LimitEvent {
  const ClearLimit();
}

sealed class LimitState extends Equatable {
  const LimitState();

  @override
  List<Object?> get props => [];
}

final class LimitInitial extends LimitState {
  const LimitInitial();
}

final class LimitLoading extends LimitState {
  const LimitLoading();
}

final class LimitResultState extends LimitState {
  final LimitResult result;

  const LimitResultState(this.result);

  @override
  List<Object?> get props => [result];
}

final class LimitError extends LimitState {
  final String message;

  const LimitError(this.message);

  @override
  List<Object?> get props => [message];
}

class LimitBloc extends Bloc<LimitEvent, LimitState> {
  final EvaluateLimit _evaluateLimit;

  LimitBloc({required EvaluateLimit evaluateLimit})
      : _evaluateLimit = evaluateLimit,
        super(const LimitInitial()) {
    on<Evaluate>(_onEvaluate);
    on<ClearLimit>(_onClear);
  }

  Future<void> _onEvaluate(Evaluate event, Emitter<LimitState> emit) async {
    emit(const LimitLoading());
    try {
      final result = await _evaluateLimit(
        event.function,
        event.variable,
        event.approachPoint,
        direction: event.direction,
      );
      emit(LimitResultState(result));
    } catch (e) {
      emit(LimitError(e.toString()));
    }
  }

  void _onClear(ClearLimit event, Emitter<LimitState> emit) {
    emit(const LimitInitial());
  }
}
