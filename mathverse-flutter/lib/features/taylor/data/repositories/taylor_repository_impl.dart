import 'package:mathverse_flutter/core/network/api_client.dart';
import 'package:mathverse_flutter/di/injection_container.dart';

import '../../domain/entities/taylor_result.dart';
import '../../domain/repositories/taylor_repository.dart';

class TaylorRepositoryImpl implements TaylorRepository {
  final ApiClient _apiClient;

  TaylorRepositoryImpl([ApiClient? apiClient]) : _apiClient = apiClient ?? sl();

  @override
  Future<TaylorResult> expand(String function, String variable, String center, int order) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/taylor/expand',
        data: {
          'function': function,
          'variable': variable,
          'center': center,
          'order': order,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return TaylorResult(
        function: function,
        variable: variable,
        center: center,
        order: order,
        result: data['result'] as String,
        terms: data['terms'] as String?,
        latexOutput: data['latex_output'] as String?,
      );
    } catch (e) {
      throw Exception('Taylor expansion error: ${e.toString()}');
    }
  }
}
