import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/taylor_result.dart';
import '../../domain/usecases/expand_taylor_series.dart';

sealed class TaylorEvent extends Equatable {
  const TaylorEvent();

  @override
  List<Object?> get props => [];
}

final class ExpandTaylor extends TaylorEvent {
  final String function;
  final String variable;
  final String center;
  final int order;

  const ExpandTaylor({
    required this.function,
    this.variable = 'x',
    this.center = '0',
    this.order = 3,
  });

  @override
  List<Object?> get props => [function, variable, center, order];
}

final class ClearTaylor extends TaylorEvent {
  const ClearTaylor();
}

sealed class TaylorState extends Equatable {
  const TaylorState();

  @override
  List<Object?> get props => [];
}

final class TaylorInitial extends TaylorState {
  const TaylorInitial();
}

final class TaylorLoading extends TaylorState {
  const TaylorLoading();
}

final class TaylorResultState extends TaylorState {
  final TaylorResult result;

  const TaylorResultState(this.result);

  @override
  List<Object?> get props => [result];
}

final class TaylorError extends TaylorState {
  final String message;

  const TaylorError(this.message);

  @override
  List<Object?> get props => [message];
}

class TaylorBloc extends Bloc<TaylorEvent, TaylorState> {
  final ExpandTaylorSeries _expandTaylorSeries;

  TaylorBloc({required ExpandTaylorSeries expandTaylorSeries})
      : _expandTaylorSeries = expandTaylorSeries,
        super(const TaylorInitial()) {
    on<ExpandTaylor>(_onExpandTaylor);
    on<ClearTaylor>(_onClear);
  }

  Future<void> _onExpandTaylor(ExpandTaylor event, Emitter<TaylorState> emit) async {
    emit(const TaylorLoading());
    try {
      final result = await _expandTaylorSeries(
        event.function,
        event.variable,
        event.center,
        event.order,
      );
      emit(TaylorResultState(result));
    } catch (e) {
      emit(TaylorError(e.toString()));
    }
  }

  void _onClear(ClearTaylor event, Emitter<TaylorState> emit) {
    emit(const TaylorInitial());
  }
}
