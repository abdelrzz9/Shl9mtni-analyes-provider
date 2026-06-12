import 'dart:math';

import '../../domain/entities/graph_data.dart';
import '../../domain/repositories/graph_repository.dart';

class GraphRepositoryImpl implements GraphRepository {
  @override
  Future<GraphData> plotFunction(String function, double xMin, double xMax, {double step = 0.1}) async {
    final points = _localPlot(function, xMin, xMax, step);
    return GraphData(
      function: function,
      xMin: xMin,
      xMax: xMax,
      points: points,
    );
  }

  List<Point> _localPlot(String function, double xMin, double xMax, double step) {
    final points = <Point>[];
    final expr = function.replaceAll(' ', '');
    for (var x = xMin; x <= xMax; x += step) {
      final y = _evaluate(expr, x);
      if (y != null && y.isFinite) {
        points.add(Point(x: x, y: y));
      }
    }
    return points;
  }

  double? _evaluate(String expr, double x) {
    try {
      if (expr == 'x' || expr == 'X') return x;
      if (expr == '-x') return -x;
      if (expr == 'x^2') return x * x;
      if (expr == 'x^3') return x * x * x;
      if (expr == 'sqrt(x)') return x >= 0 ? sqrt(x) : null;
      if (expr == 'sin(x)') return sin(x);
      if (expr == 'cos(x)') return cos(x);
      if (expr == 'tan(x)') return tan(x);
      if (expr == 'exp(x)' || expr == 'e^x') return exp(x);
      if (expr == 'ln(x)' || expr == 'log(x)') return x > 0 ? log(x) : null;
      if (expr == 'abs(x)') return x.abs();
      if (expr.contains('*x')) {
        final parts = expr.split('*x');
        final coeff = double.tryParse(parts[0]);
        if (coeff != null) return coeff * x;
      }
      if (_isNumeric(expr)) return double.parse(expr);
      return null;
    } catch (_) {
      return null;
    }
  }

  bool _isNumeric(String s) => double.tryParse(s) != null;
}
