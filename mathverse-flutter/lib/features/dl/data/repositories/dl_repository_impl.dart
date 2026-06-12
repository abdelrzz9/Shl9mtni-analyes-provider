import 'package:mathverse_flutter/di/injection_container.dart';
import 'package:mathverse_flutter/core/network/api_client.dart';

import '../../domain/entities/dl_result.dart';
import '../../domain/repositories/dl_repository.dart';

class DLRepositoryImpl implements DLRepository {
  final ApiClient _apiClient;

  DLRepositoryImpl([ApiClient? apiClient]) : _apiClient = apiClient ?? sl();

  @override
  Future<DLResult> expand(String function, String variable, String center, int order) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/taylor/expand',
        data: {
          'function': function,
          'variable': variable,
          'center': '0',
          'order': order,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return DLResult(
        function: function,
        variable: variable,
        center: center,
        order: order,
        result: data['result'] as String,
        terms: data['terms'] as String?,
        latexOutput: data['latex_output'] as String?,
      );
    } catch (e) {
      throw Exception('Series expansion error: ${e.toString()}');
    }
  }
}
