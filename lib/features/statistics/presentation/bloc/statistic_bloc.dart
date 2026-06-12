import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/statistic_result.dart';
import '../../domain/usecases/calculate_statistic.dart';

sealed class StatisticEvent extends Equatable {
  const StatisticEvent();

  @override
  List<Object?> get props => [];
}

final class Calculate extends StatisticEvent {
  final String operation;
  final List<double> data;
  final List<double>? data2;

  const Calculate({
    required this.operation,
    required this.data,
    this.data2,
  });

  @override
  List<Object?> get props => [operation, data, data2];
}

final class ClearStatistic extends StatisticEvent {
  const ClearStatistic();
}

sealed class StatisticState extends Equatable {
  const StatisticState();

  @override
  List<Object?> get props => [];
}

final class StatisticInitial extends StatisticState {
  const StatisticInitial();
}

final class StatisticLoading extends StatisticState {
  const StatisticLoading();
}

final class StatisticResultState extends StatisticState {
  final StatisticResult result;

  const StatisticResultState(this.result);

  @override
  List<Object?> get props => [result];
}

final class StatisticError extends StatisticState {
  final String message;

  const StatisticError(this.message);

  @override
  List<Object?> get props => [message];
}

class StatisticBloc extends Bloc<StatisticEvent, StatisticState> {
  final CalculateStatistic _calculateStatistic;

  StatisticBloc({required CalculateStatistic calculateStatistic})
      : _calculateStatistic = calculateStatistic,
        super(const StatisticInitial()) {
    on<Calculate>(_onCalculate);
    on<ClearStatistic>(_onClear);
  }

  Future<void> _onCalculate(Calculate event, Emitter<StatisticState> emit) async {
    emit(const StatisticLoading());
    try {
      final result = await _calculateStatistic(
        operation: event.operation,
        data: event.data,
        data2: event.data2,
      );
      emit(StatisticResultState(result));
    } catch (e) {
      emit(StatisticError(e.toString()));
    }
  }

  void _onClear(ClearStatistic event, Emitter<StatisticState> emit) {
    emit(const StatisticInitial());
  }
}
