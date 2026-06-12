import 'package:mathverse_flutter/di/injection_container.dart';
import 'package:mathverse_flutter/core/network/api_client.dart';

import '../../domain/entities/graph_data.dart';
import '../../domain/repositories/graph_repository.dart';

class GraphRepositoryImpl implements GraphRepository {
  final ApiClient _apiClient;

  GraphRepositoryImpl([ApiClient? apiClient]) : _apiClient = apiClient ?? sl();

  @override
  Future<GraphData> plotFunction(String function, double xMin, double xMax, {double step = 0.1}) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/graph/plot',
        data: {
          'function': function,
          'x_min': xMin,
          'x_max': xMax,
          'step': step,
        },
      );
      final data = response.data as Map<String, dynamic>;
      final pointsJson = data['points'] as List<dynamic>;
      final points = pointsJson.map((p) {
        final point = p as Map<String, dynamic>;
        return Point(
          x: (point['x'] as num).toDouble(),
          y: (point['y'] as num).toDouble(),
        );
      }).toList();
      return GraphData(
        function: function,
        xMin: xMin,
        xMax: xMax,
        points: points,
        latexOutput: data['latex_output'] as String?,
      );
    } catch (e) {
      throw Exception('Graph plotting error: ${e.toString()}');
    }
  }
}
