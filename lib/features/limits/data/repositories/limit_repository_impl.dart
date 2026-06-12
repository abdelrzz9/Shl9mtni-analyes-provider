import '../../domain/entities/limit_result.dart';
import '../../domain/repositories/limit_repository.dart';

class LimitRepositoryImpl implements LimitRepository {
  @override
  Future<LimitResult> evaluateLimit(String function, String variable, String approachPoint, {String? direction}) async {
    final result = _localEvaluateLimit(function, variable, approachPoint, direction);
    return LimitResult(
      function: function,
      variable: variable,
      approachPoint: approachPoint,
      direction: direction,
      result: result,
    );
  }

  String _localEvaluateLimit(String function, String variable, String approachPoint, String? direction) {
    final expr = function.replaceAll(' ', '');
    if (expr == variable) {
      if (approachPoint == '0') return '0';
      if (approachPoint == 'inf') return 'inf';
      return approachPoint;
    }
    if (_isNumeric(expr)) return expr;
    if (expr == '1/$variable') {
      if (approachPoint == '0') {
        if (direction == '-' || direction == 'left') return '-inf';
        return 'inf';
      }
      if (approachPoint == 'inf') return '0';
      return '1/${approachPoint}';
    }
    if (expr == 'sin($variable)/$variable') {
      if (approachPoint == '0') return '1';
    }
    if (expr == 'sin($variable)') {
      if (approachPoint == '0') return '0';
      if (approachPoint == 'inf') return 'undefined (oscillates)';
    }
    if (expr == 'cos($variable)') {
      if (approachPoint == '0') return '1';
      if (approachPoint == 'inf') return 'undefined (oscillates)';
    }
    if (approachPoint == 'inf') {
      if (expr.contains('^')) return 'inf';
      if (expr.contains('exp($variable)')) return 'inf';
      if (expr.contains('ln($variable)') || expr.contains('log($variable)')) return 'inf';
    }
    return 'See math engine for detailed result';
  }

  bool _isNumeric(String s) => double.tryParse(s) != null;
}
