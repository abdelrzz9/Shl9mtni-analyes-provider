import 'package:mathverse_flutter/core/network/api_client.dart';
import 'package:mathverse_flutter/di/injection_container.dart';

import '../../domain/entities/limit_result.dart';
import '../../domain/repositories/limit_repository.dart';

class LimitRepositoryImpl implements LimitRepository {
  final ApiClient _apiClient;

  LimitRepositoryImpl([ApiClient? apiClient]) : _apiClient = apiClient ?? sl();

  @override
  Future<LimitResult> evaluateLimit(String function, String variable, String approachPoint, {String? direction}) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/limits/evaluate',
        data: {
          'function': function,
          'variable': variable,
          'approach_point': approachPoint,
          'direction': direction,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return LimitResult(
        function: function,
        variable: variable,
        approachPoint: approachPoint,
        direction: direction,
        result: data['result'] as String,
        steps: data['steps'] as String?,
        latexOutput: data['latex_output'] as String?,
      );
    } catch (e) {
      throw Exception('Limit evaluation error: ${e.toString()}');
    }
  }
}
