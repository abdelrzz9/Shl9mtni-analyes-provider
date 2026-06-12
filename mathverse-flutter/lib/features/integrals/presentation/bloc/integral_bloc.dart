import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/integral_result.dart';
import '../../domain/usecases/integrate_function.dart';

sealed class IntegralEvent extends Equatable {
  const IntegralEvent();

  @override
  List<Object?> get props => [];
}

final class Integrate extends IntegralEvent {
  final String function;
  final String variable;
  final String? lowerBound;
  final String? upperBound;

  const Integrate({
    required this.function,
    this.variable = 'x',
    this.lowerBound,
    this.upperBound,
  });

  @override
  List<Object?> get props => [function, variable, lowerBound, upperBound];
}

final class ClearIntegral extends IntegralEvent {
  const ClearIntegral();
}

sealed class IntegralState extends Equatable {
  const IntegralState();

  @override
  List<Object?> get props => [];
}

final class IntegralInitial extends IntegralState {
  const IntegralInitial();
}

final class IntegralLoading extends IntegralState {
  const IntegralLoading();
}

final class IntegralResultState extends IntegralState {
  final IntegralResult result;

  const IntegralResultState(this.result);

  @override
  List<Object?> get props => [result];
}

final class IntegralError extends IntegralState {
  final String message;

  const IntegralError(this.message);

  @override
  List<Object?> get props => [message];
}

class IntegralBloc extends Bloc<IntegralEvent, IntegralState> {
  final IntegrateFunction _integrateFunction;

  IntegralBloc({required this._integrateFunction})
      : super(const IntegralInitial()) {
    on<Integrate>(_onIntegrate);
    on<ClearIntegral>(_onClear);
  }

  Future<void> _onIntegrate(Integrate event, Emitter<IntegralState> emit) async {
    emit(const IntegralLoading());
    try {
      final result = await _integrateFunction(
        event.function,
        event.variable,
        lowerBound: event.lowerBound,
        upperBound: event.upperBound,
      );
      emit(IntegralResultState(result));
    } catch (e) {
      emit(IntegralError(e.toString()));
    }
  }

  void _onClear(ClearIntegral event, Emitter<IntegralState> emit) {
    emit(const IntegralInitial());
  }
}
