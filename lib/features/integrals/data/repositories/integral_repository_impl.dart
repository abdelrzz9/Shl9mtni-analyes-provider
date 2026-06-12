import '../../domain/entities/integral_result.dart';
import '../../domain/repositories/integral_repository.dart';

class IntegralRepositoryImpl implements IntegralRepository {
  @override
  Future<IntegralResult> integrate(String function, String variable, {String? lowerBound, String? upperBound}) async {
    final result = _localIntegrate(function, variable, lowerBound, upperBound);
    return IntegralResult(
      function: function,
      variable: variable,
      lowerBound: lowerBound,
      upperBound: upperBound,
      result: result,
    );
  }

  String _localIntegrate(String function, String variable, String? lowerBound, String? upperBound) {
    final expr = function.replaceAll(' ', '');
    if (expr.contains('^')) {
      final parts = expr.split('^');
      if (parts[0] == variable) {
        final exp = int.tryParse(parts[1]);
        if (exp != null) {
          final newExp = exp + 1;
          return '($variable^$newExp)/$newExp';
        }
      }
    }
    if (expr == variable) return '($variable^2)/2';
    if (expr == '1/$variable' || expr == '1/$variable') return 'ln|$variable|';
    if (expr == 'sin($variable)') return '-cos($variable)';
    if (expr == 'cos($variable)') return 'sin($variable)';
    if (expr == 'exp($variable)' || expr == 'e^$variable') return 'exp($variable)';
    if (_isNumeric(expr)) {
      if (upperBound != null && lowerBound != null) {
        return '${expr}*($upperBound - $lowerBound)';
      }
      return '$expr*$variable';
    }
    return 'See math engine for detailed result';
  }

  bool _isNumeric(String s) => double.tryParse(s) != null;
}
