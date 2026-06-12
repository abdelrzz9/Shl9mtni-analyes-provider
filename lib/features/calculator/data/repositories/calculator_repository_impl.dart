import 'dart:async';

import '../../domain/entities/calculation_result.dart';
import '../../domain/repositories/calculator_repository.dart';
import '../../domain/usecases/evaluate_expression.dart';

class CalculatorRepositoryImpl implements CalculatorRepository {
  final LocalCalculator _calculator = LocalCalculator();
  final StreamController<String> _expressionController = StreamController<String>.broadcast();

  @override
  Future<CalculationResult> evaluate(String expression) async {
    try {
      final result = _calculator.evaluate(expression);
      _expressionController.add(expression);
      return CalculationResult(
        expression: expression,
        result: result,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Calculation error: ${e.toString()}');
    }
  }

  @override
  Stream<String> getExpressionStream() => _expressionController.stream;

  @override
  void dispose() {
    _expressionController.close();
  }
}
