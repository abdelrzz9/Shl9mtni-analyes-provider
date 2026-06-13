import 'package:flutter_test/flutter_test.dart';
import 'package:mathverse_flutter/features/calculator/data/repositories/calculator_repository_impl.dart';
import 'package:mathverse_flutter/features/calculator/domain/entities/calculation_result.dart';
import 'package:mathverse_flutter/features/calculator/domain/repositories/calculator_repository.dart';

void main() {
  group('CalculatorRepository', () {
    test('CalculatorRepository implements CalculatorRepository interface', () {
      final repo = CalculatorRepositoryImpl();
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

    group('Local evaluation', () {
      late CalculatorRepositoryImpl repo;

      setUp(() {
        repo = CalculatorRepositoryImpl();
      });

      test('adds two numbers', () async {
        final result = await repo.evaluate('2+2');
        expect(result.result, closeTo(4.0, 1e-10));
      });

      test('subtracts numbers', () async {
        final result = await repo.evaluate('10-3');
        expect(result.result, closeTo(7.0, 1e-10));
      });

      test('multiplies numbers', () async {
        final result = await repo.evaluate('6*7');
        expect(result.result, closeTo(42.0, 1e-10));
      });

      test('divides numbers', () async {
        final result = await repo.evaluate('15/3');
        expect(result.result, closeTo(5.0, 1e-10));
      });

      test('handles power operator', () async {
        final result = await repo.evaluate('2^3');
        expect(result.result, closeTo(8.0, 1e-10));
      });

      test('handles parentheses', () async {
        final result = await repo.evaluate('(2+3)*4');
        expect(result.result, closeTo(20.0, 1e-10));
      });

      test('handles operator precedence', () async {
        final result = await repo.evaluate('2+3*4');
        expect(result.result, closeTo(14.0, 1e-10));
      });
    });
  });
}
