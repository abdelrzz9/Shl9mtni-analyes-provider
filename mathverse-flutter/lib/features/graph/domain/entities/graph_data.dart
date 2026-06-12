import 'package:equatable/equatable.dart';

class Point extends Equatable {
  final double x;
  final double y;

  const Point({required this.x, required this.y});

  @override
  List<Object?> get props => [x, y];
}

class GraphData extends Equatable {
  final String function;
  final double xMin;
  final double xMax;
  final List<Point> points;
  final String? latexOutput;

  const GraphData({
    required this.function,
    required this.xMin,
    required this.xMax,
    required this.points,
    this.latexOutput,
  });

  @override
  List<Object?> get props => [function, xMin, xMax, points, latexOutput];
}
