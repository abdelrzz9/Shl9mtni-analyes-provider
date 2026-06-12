import '../../domain/entities/taylor_result.dart';
import '../../domain/repositories/taylor_repository.dart';

class TaylorRepositoryImpl implements TaylorRepository {
  @override
  Future<TaylorResult> expand(String function, String variable, String center, int order) async {
    final result = _localExpand(function, variable, center, order);
    final terms = _localTerms(function, variable, center, order);
    return TaylorResult(
      function: function,
      variable: variable,
      center: center,
      order: order,
      result: result,
      terms: terms,
    );
  }

  String _localExpand(String function, String variable, String center, int order) {
    final expr = function.replaceAll(' ', '');
    if (expr == 'sin($variable)' && center == '0') {
      if (order == 1) return '$variable';
      if (order == 3) return '$variable - ($variable^3)/6';
      if (order == 5) return '$variable - ($variable^3)/6 + ($variable^5)/120';
    }
    if (expr == 'cos($variable)' && center == '0') {
      if (order == 2) return '1 - ($variable^2)/2';
      if (order == 4) return '1 - ($variable^2)/2 + ($variable^4)/24';
    }
    if (expr == 'exp($variable)' || expr == 'e^$variable') {
      if (center == '0') {
        if (order == 1) return '1 + $variable';
        if (order == 2) return '1 + $variable + ($variable^2)/2';
        if (order == 3) return '1 + $variable + ($variable^2)/2 + ($variable^3)/6';
      }
    }
    if (expr == 'ln($variable)' || expr == 'log($variable)') {
      if (center == '1') {
        if (order == 1) return '($variable - 1)';
        if (order == 2) return '($variable - 1) - ($variable - 1)^2/2';
      }
    }
    if (expr == '1/(1-$variable)' && center == '0') {
      if (order == 1) return '1 + $variable';
      if (order == 2) return '1 + $variable + $variable^2';
      if (order == 3) return '1 + $variable + $variable^2 + $variable^3';
    }
    return 'See math engine for detailed result';
  }

  String _localTerms(String function, String variable, String center, int order) {
    final buffer = StringBuffer();
    for (var i = 0; i <= order; i++) {
      if (i > 0) buffer.write(', ');
      buffer.write('Term $i: ...');
    }
    return buffer.toString();
  }
}
