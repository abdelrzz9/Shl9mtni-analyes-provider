import '../../domain/entities/derivative_result.dart';
import '../../domain/repositories/derivative_repository.dart';

class DerivativeRepositoryImpl implements DerivativeRepository {
  @override
  Future<DerivativeResult> differentiate(String function, String variable, {int order = 1}) async {
    // This will call the Python math engine service
    // For now, we use a local parser
    final result = _localDifferentiate(function, variable, order);
    return DerivativeResult(
      function: function,
      variable: variable,
      order: order,
      result: result,
    );
  }

  String _localDifferentiate(String function, String variable, int order) {
    // Basic symbolic differentiation for common cases
    final expr = function.replaceAll(' ', '');
    if (expr.contains('^')) {
      final parts = expr.split('^');
      if (parts[0] == variable && order == 1) {
        final exp = parts[1];
        return '$exp*$variable^(${int.parse(exp) - 1})';
      }
    }
    if (expr == 'sin($variable)') return 'cos($variable)';
    if (expr == 'cos($variable)') return '-sin($variable)';
    if (expr == 'tan($variable)') return 'sec^2($variable)';
    if (expr == 'exp($variable)' || expr == 'e^$variable') return 'exp($variable)';
    if (expr == 'ln($variable)' || expr == 'log($variable)') return '1/$variable';
    if (expr == variable) return '1';
    if (_isNumeric(expr)) return '0';
    return 'See math engine for detailed result';
  }

  bool _isNumeric(String s) => double.tryParse(s) != null;
}
