import 'package:flutter_test/flutter_test.dart';
import 'package:math_app/features/calculator/domain/usecases/evaluate_expression.dart';

void main() {
  late LocalCalculator calculator;

  setUp(() {
    calculator = LocalCalculator();
  });

  group('LocalCalculator', () {
    test('evaluates simple addition', () {
      expect(calculator.evaluate('2+3'), closeTo(5, 0.001));
    });

    test('evaluates subtraction', () {
      expect(calculator.evaluate('10-4'), closeTo(6, 0.001));
    });

    test('evaluates multiplication', () {
      expect(calculator.evaluate('3*4'), closeTo(12, 0.001));
    });

    test('evaluates division', () {
      expect(calculator.evaluate('10/2'), closeTo(5, 0.001));
    });

    test('evaluates complex expression', () {
      expect(calculator.evaluate('2+3*4'), closeTo(14, 0.001));
    });

    test('evaluates expression with parentheses', () {
      expect(calculator.evaluate('(2+3)*4'), closeTo(20, 0.001));
    });

    test('evaluates nested parentheses', () {
      expect(calculator.evaluate('((2+3)*2)'), closeTo(10, 0.001));
    });

    test('evaluates power', () {
      expect(calculator.evaluate('2^3'), closeTo(8, 0.001));
    });

    test('evaluates unary minus', () {
      expect(calculator.evaluate('-5+3'), closeTo(-2, 0.001));
    });

    test('handles pi constant', () {
      expect(calculator.evaluate('π'), closeTo(3.14159, 0.001));
    });

    test('throws on division by zero', () {
      expect(() => calculator.evaluate('1/0'), throwsArgumentError);
    });

    test('evaluates long expression', () {
      expect(calculator.evaluate('1+2*3-4/2'), closeTo(5, 0.001));
    });

    test('evaluates power before multiplication', () {
      expect(calculator.evaluate('2*3^2'), closeTo(18, 0.001));
    });
  });
}
