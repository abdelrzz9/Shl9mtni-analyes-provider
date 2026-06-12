import '../entities/graph_data.dart';

abstract class GraphRepository {
  Future<GraphData> plotFunction(String function, double xMin, double xMax, {double step = 0.1});
}
