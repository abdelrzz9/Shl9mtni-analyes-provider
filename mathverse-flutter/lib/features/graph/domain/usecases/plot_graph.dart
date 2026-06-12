import '../entities/graph_data.dart';
import '../repositories/graph_repository.dart';

class PlotGraph {
  final GraphRepository repository;

  PlotGraph(this.repository);

  Future<GraphData> call(String function, double xMin, double xMax, {double step = 0.1}) {
    return repository.plotFunction(function, xMin, xMax, step: step);
  }
}
