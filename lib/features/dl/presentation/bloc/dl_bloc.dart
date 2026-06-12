import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/dl_result.dart';
import '../../domain/usecases/expand_dl.dart';

sealed class DLEvent extends Equatable {
  const DLEvent();

  @override
  List<Object?> get props => [];
}

final class ExpandDLSeries extends DLEvent {
  final String function;
  final String variable;
  final String center;
  final int order;

  const ExpandDLSeries({
    required this.function,
    this.variable = 'x',
    this.center = '0',
    this.order = 3,
  });

  @override
  List<Object?> get props => [function, variable, center, order];
}

final class ClearDL extends DLEvent {
  const ClearDL();
}

sealed class DLState extends Equatable {
  const DLState();

  @override
  List<Object?> get props => [];
}

final class DLInitial extends DLState {
  const DLInitial();
}

final class DLLoading extends DLState {
  const DLLoading();
}

final class DLResultState extends DLState {
  final DLResult result;

  const DLResultState(this.result);

  @override
  List<Object?> get props => [result];
}

final class DLError extends DLState {
  final String message;

  const DLError(this.message);

  @override
  List<Object?> get props => [message];
}

class DLBloc extends Bloc<DLEvent, DLState> {
  final ExpandDL _expandDL;

  DLBloc({required ExpandDL expandDL})
      : _expandDL = expandDL,
        super(const DLInitial()) {
    on<ExpandDLSeries>(_onExpandDL);
    on<ClearDL>(_onClear);
  }

  Future<void> _onExpandDL(ExpandDLSeries event, Emitter<DLState> emit) async {
    emit(const DLLoading());
    try {
      final result = await _expandDL(
        event.function,
        event.variable,
        event.center,
        event.order,
      );
      emit(DLResultState(result));
    } catch (e) {
      emit(DLError(e.toString()));
    }
  }

  void _onClear(ClearDL event, Emitter<DLState> emit) {
    emit(const DLInitial());
  }
}
