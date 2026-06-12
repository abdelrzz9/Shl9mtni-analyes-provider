import 'package:flutter_test/flutter_test.dart';
import 'package:mathverse_flutter/core/network/api_client.dart';
import 'package:mathverse_flutter/features/calculator/data/repositories/calculator_repository_impl.dart';
import 'package:mathverse_flutter/features/calculator/domain/entities/calculation_result.dart';
import 'package:mathverse_flutter/features/calculator/domain/repositories/calculator_repository.dart';

void main() {
  group('CalculatorRepository', () {
    test('CalculatorRepository implements CalculatorRepository interface', () {
      final repo = CalculatorRepositoryImpl(ApiClient());
      expect(repo, isA<CalculatorRepository>());
    });

    test('CalculationResult creates correctly', () {
      final result = CalculationResult(
        expression: '2+2',
        result: 4.0,
        timestamp: DateTime.now(),
      );
      expect(result.expression, '2+2');
      expect(result.result, 4.0);
    });

    test('CalculationResult supports equality', () {
      final now = DateTime.now();
      final a = CalculationResult(expression: '2+2', result: 4.0, timestamp: now);
      final b = CalculationResult(expression: '2+2', result: 4.0, timestamp: now);
      expect(a, equals(b));
    });
  });
}
