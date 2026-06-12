import '../../domain/entities/dl_result.dart';
import '../../domain/repositories/dl_repository.dart';

class DLRepositoryImpl implements DLRepository {
  @override
  Future<DLResult> expand(String function, String variable, String center, int order) async {
    final result = _localExpand(function, variable, center, order);
    final terms = _localTerms(function, variable, center, order);
    return DLResult(
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
      if (order == 1) return '$variable + o($variable)';
      if (order == 3) return '$variable - ($variable^3)/6 + o($variable^3)';
      if (order == 5) return '$variable - ($variable^3)/6 + ($variable^5)/120 + o($variable^5)';
    }
    if (expr == 'cos($variable)' && center == '0') {
      if (order == 2) return '1 - ($variable^2)/2 + o($variable^2)';
      if (order == 4) return '1 - ($variable^2)/2 + ($variable^4)/24 + o($variable^4)';
    }
    if (expr == 'exp($variable)' || expr == 'e^$variable') {
      if (center == '0') {
        if (order == 1) return '1 + $variable + o($variable)';
        if (order == 2) return '1 + $variable + ($variable^2)/2 + o($variable^2)';
        if (order == 3) return '1 + $variable + ($variable^2)/2 + ($variable^3)/6 + o($variable^3)';
      }
    }
    if (expr == 'ln(1+$variable)' && center == '0') {
      if (order == 1) return '$variable + o($variable)';
      if (order == 2) return '$variable - ($variable^2)/2 + o($variable^2)';
      if (order == 3) return '$variable - ($variable^2)/2 + ($variable^3)/3 + o($variable^3)';
    }
    if (expr == '1/(1-$variable)' && center == '0') {
      if (order == 1) return '1 + $variable + o($variable)';
      if (order == 2) return '1 + $variable + $variable^2 + o($variable^2)';
      if (order == 3) return '1 + $variable + $variable^2 + $variable^3 + o($variable^3)';
    }
    if (expr == 'sqrt(1+$variable)' && center == '0') {
      if (order == 1) return '1 + $variable/2 + o($variable)';
      if (order == 2) return '1 + $variable/2 - ($variable^2)/8 + o($variable^2)';
    }
    return 'See math engine for detailed result';
  }

  String _localTerms(String function, String variable, String center, int order) {
    final buffer = StringBuffer();
    for (var i = 0; i <= order; i++) {
      if (i > 0) buffer.write(', ');
      buffer.write('Order $i: ...');
    }
    return buffer.toString();
  }
}
