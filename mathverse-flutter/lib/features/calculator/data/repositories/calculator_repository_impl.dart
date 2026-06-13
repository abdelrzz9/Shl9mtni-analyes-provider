import 'dart:async';

import 'package:math_expressions/math_expressions.dart';

import '../../domain/entities/calculation_result.dart';
import '../../domain/repositories/calculator_repository.dart';

class CalculatorRepositoryImpl implements CalculatorRepository {
  final StreamController<String> _expressionController = StreamController<String>.broadcast();

  @override
  Future<CalculationResult> evaluate(String expression) async {
    try {
      final cleaned = expression
          .replaceAll('\u00D7', '*')
          .replaceAll('\u00F7', '/')
          .replaceAll('\u03C0', 'pi')
          .replaceAll('^', '^');

      final parser = ShuntingYardParser();
      final exp = parser.parse(cleaned);
      final cm = ContextModel();
      final result = exp.evaluate(EvaluationType.REAL, cm);

      _expressionController.add(expression);

      return CalculationResult(
        expression: expression,
        result: (result as double),
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
