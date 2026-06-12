import 'package:mathverse_flutter/core/network/api_client.dart';
import 'package:mathverse_flutter/di/injection_container.dart';

import '../../domain/entities/derivative_result.dart';
import '../../domain/repositories/derivative_repository.dart';

class DerivativeRepositoryImpl implements DerivativeRepository {
  final ApiClient _apiClient;

  DerivativeRepositoryImpl([ApiClient? apiClient]) : _apiClient = apiClient ?? sl();

  @override
  Future<DerivativeResult> differentiate(String function, String variable, {int order = 1}) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/derivatives/differentiate',
        data: {
          'function': function,
          'variable': variable,
          'order': order,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return DerivativeResult(
        function: function,
        variable: variable,
        order: order,
        result: data['result'] as String,
        steps: data['steps'] as String?,
        latexOutput: data['latex_output'] as String?,
      );
    } catch (e) {
      throw Exception('Differentiation error: ${e.toString()}');
    }
  }
}
