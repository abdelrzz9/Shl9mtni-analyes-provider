import 'dart:async';

import 'package:mathverse_flutter/core/network/api_client.dart';
import 'package:mathverse_flutter/di/injection_container.dart';

import '../../domain/entities/calculation_result.dart';
import '../../domain/repositories/calculator_repository.dart';

class CalculatorRepositoryImpl implements CalculatorRepository {
  final ApiClient _apiClient;
  final StreamController<String> _expressionController = StreamController<String>.broadcast();

  CalculatorRepositoryImpl([ApiClient? apiClient]) : _apiClient = apiClient ?? sl();

  @override
  Future<CalculationResult> evaluate(String expression) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/calculator/evaluate',
        data: {'expression': expression},
      );
      final data = response.data as Map<String, dynamic>;
      _expressionController.add(expression);
      return CalculationResult(
        expression: expression,
        result: (data['result'] as num).toDouble(),
        latexOutput: data['latex_output'] as String?,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Calculation error: ${e.toString()}');
    }
  }

  @override
  Stream<String> getExpressionStream() => _expressionController.stream;

  @override
  void dispose() {
    _expressionController.close();
  }
}
