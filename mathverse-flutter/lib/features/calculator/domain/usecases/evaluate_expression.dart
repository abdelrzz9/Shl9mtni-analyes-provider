import '../entities/calculation_result.dart';
import '../repositories/calculator_repository.dart';

class EvaluateExpression {
  final CalculatorRepository repository;

  EvaluateExpression(this.repository);

  Future<CalculationResult> call(String expression) {
    return repository.evaluate(expression);
  }
}
