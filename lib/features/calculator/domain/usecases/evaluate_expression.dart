import 'dart:math';

import '../entities/calculation_result.dart';
import '../repositories/calculator_repository.dart';

class EvaluateExpression {
  final CalculatorRepository repository;

  EvaluateExpression(this.repository);

  Future<CalculationResult> call(String expression) {
    return repository.evaluate(expression);
  }
}

class LocalCalculator {
  double evaluate(String expression) {
    final sanitized = expression
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('π', pi.toString())
        .replaceAll('e', exp(1).toString())
        .replaceAll('sin', 's')
        .replaceAll('cos', 'c')
        .replaceAll('tan', 't')
        .replaceAll('log', 'g')
        .replaceAll('ln', 'l')
        .replaceAll('sqrt', 'q')
        .replaceAll('^', '**');

    return _parseExpression(sanitized.replaceAll(' ', ''));
  }

  int _pos = 0;
  String _input = '';

  double _parseExpression(String input) {
    _pos = 0;
    _input = input;
    final result = _parseAddSubtract();
    if (_pos < _input.length) {
      throw FormatException('Unexpected character: ${_input[_pos]}');
    }
    return result;
  }

  double _parseAddSubtract() {
    var left = _parseMultiplyDivide();
    while (_pos < _input.length) {
      final char = _input[_pos];
      if (char == '+') {
        _pos++;
        left += _parseMultiplyDivide();
      } else if (char == '-') {
        _pos++;
        left -= _parseMultiplyDivide();
      } else {
        break;
      }
    }
    return left;
  }

  double _parseMultiplyDivide() {
    var left = _parsePower();
    while (_pos < _input.length) {
      final char = _input[_pos];
      if (char == '*') {
        _pos++;
        left *= _parsePower();
      } else if (char == '/') {
        _pos++;
        final divisor = _parsePower();
        if (divisor == 0) throw ArgumentError('Division by zero');
        left /= divisor;
      } else {
        break;
      }
    }
    return left;
  }

  double _parsePower() {
    var left = _parseUnary();
    if (_pos + 1 < _input.length && _input.substring(_pos, _pos + 2) == '**') {
      _pos += 2;
      left = pow(left, _parsePower()).toDouble();
    }
    return left;
  }

  double _parseUnary() {
    if (_pos >= _input.length) throw FormatException('Unexpected end');
    if (_input[_pos] == '-') {
      _pos++;
      return -_parseUnary();
    }
    if (_input[_pos] == '+') {
      _pos++;
      return _parseUnary();
    }
    return _parseFunctionOrNumber();
  }

  double _parseFunctionOrNumber() {
    if (_pos >= _input.length) throw FormatException('Unexpected end');

    final char = _input[_pos];

    if (char == 's') {
      _pos++;
      return sin(_parseParenthesis());
    }
    if (char == 'c') {
      _pos++;
      return cos(_parseParenthesis());
    }
    if (char == 't') {
      _pos++;
      return tan(_parseParenthesis());
    }
    if (char == 'g') {
      _pos++;
      return log(_parseParenthesis()) / ln10;
    }
    if (char == 'l') {
      _pos++;
      return log(_parseParenthesis());
    }
    if (char == 'q') {
      _pos++;
      return sqrt(_parseParenthesis());
    }
    if (char == '(') {
      return _parseParenthesis();
    }

    return _parseNumber();
  }

  double _parseParenthesis() {
    if (_input[_pos] != '(') throw FormatException('Expected (');
    _pos++;
    final value = _parseAddSubtract();
    if (_pos >= _input.length || _input[_pos] != ')') {
      throw FormatException('Expected )');
    }
    _pos++;
    return value;
  }

  double _parseNumber() {
    final start = _pos;
    while (_pos < _input.length && (_isDigit(_input[_pos]) || _input[_pos] == '.')) {
      _pos++;
    }
    if (_pos == start) throw FormatException('Expected number at position $_pos');
    return double.parse(_input.substring(start, _pos));
  }

  bool _isDigit(String char) {
    return char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57;
  }
}
