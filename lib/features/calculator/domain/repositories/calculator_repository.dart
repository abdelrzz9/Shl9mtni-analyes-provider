import '../entities/calculation_result.dart';

abstract class CalculatorRepository {
  Future<CalculationResult> evaluate(String expression);
  Stream<String> getExpressionStream();
  void dispose();
}
