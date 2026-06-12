import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/calculation_result.dart';
import '../../domain/usecases/evaluate_expression.dart';

sealed class CalculatorEvent extends Equatable {
  const CalculatorEvent();

  @override
  List<Object?> get props => [];
}

final class ExpressionChanged extends CalculatorEvent {
  final String expression;

  const ExpressionChanged(this.expression);

  @override
  List<Object?> get props => [expression];
}

final class Calculate extends CalculatorEvent {
  final String expression;

  const Calculate(this.expression);

  @override
  List<Object?> get props => [expression];
}

final class ClearExpression extends CalculatorEvent {
  const ClearExpression();
}

sealed class CalculatorState extends Equatable {
  const CalculatorState();

  @override
  List<Object?> get props => [];
}

final class CalculatorInitial extends CalculatorState {
  const CalculatorInitial();
}

final class CalculatorLoading extends CalculatorState {
  const CalculatorLoading();
}

final class CalculatorResultState extends CalculatorState {
  final CalculationResult result;
  final String expression;

  const CalculatorResultState({required this.result, required this.expression});

  @override
  List<Object?> get props => [result, expression];
}

final class CalculatorError extends CalculatorState {
  final String message;
  final String expression;

  const CalculatorError({required this.message, required this.expression});

  @override
  List<Object?> get props => [message, expression];
}

class CalculatorBloc extends Bloc<CalculatorEvent, CalculatorState> {
  final EvaluateExpression _evaluateExpression;

  CalculatorBloc({required this._evaluateExpression})
      : super(const CalculatorInitial()) {
    on<ExpressionChanged>(_onExpressionChanged);
    on<Calculate>(_onCalculate);
    on<ClearExpression>(_onClear);
  }

  String _expression = '';

  String get expression => _expression;

  void _onExpressionChanged(ExpressionChanged event, Emitter<CalculatorState> emit) {
    _expression = event.expression;
    if (event.expression.isEmpty) {
      emit(const CalculatorInitial());
    }
  }

  Future<void> _onCalculate(Calculate event, Emitter<CalculatorState> emit) async {
    emit(const CalculatorLoading());
    try {
      final result = await _evaluateExpression(event.expression);
      _expression = event.expression;
      emit(CalculatorResultState(result: result, expression: event.expression));
    } catch (e) {
      emit(CalculatorError(message: e.toString(), expression: event.expression));
    }
  }

  void _onClear(ClearExpression event, Emitter<CalculatorState> emit) {
    _expression = '';
    emit(const CalculatorInitial());
  }
}
