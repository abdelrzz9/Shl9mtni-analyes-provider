import 'package:mathverse_flutter/di/injection_container.dart';
import 'package:mathverse_flutter/core/network/api_client.dart';

import '../../domain/entities/integral_result.dart';
import '../../domain/repositories/integral_repository.dart';

class IntegralRepositoryImpl implements IntegralRepository {
  final ApiClient _apiClient;

  IntegralRepositoryImpl([ApiClient? apiClient]) : _apiClient = apiClient ?? sl();

  @override
  Future<IntegralResult> integrate(String function, String variable, {String? lowerBound, String? upperBound}) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/integrals/integrate',
        data: {
          'function': function,
          'variable': variable,
          'lower_bound': lowerBound,
          'upper_bound': upperBound,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return IntegralResult(
        function: function,
        variable: variable,
        lowerBound: lowerBound,
        upperBound: upperBound,
        result: data['result'] as String,
        steps: data['steps'] as String?,
        latexOutput: data['latex_output'] as String?,
      );
    } catch (e) {
      throw Exception('Integration error: ${e.toString()}');
    }
  }
}
