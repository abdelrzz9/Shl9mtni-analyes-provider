import 'package:mathverse_flutter/di/injection_container.dart';
import 'package:mathverse_flutter/core/network/api_client.dart';

import '../../domain/entities/matrix_result.dart';
import '../../domain/repositories/matrix_repository.dart';

class MatrixRepositoryImpl implements MatrixRepository {
  final ApiClient _apiClient;

  MatrixRepositoryImpl([ApiClient? apiClient]) : _apiClient = apiClient ?? sl();

  @override
  Future<MatrixResult> add(String matrixA, String matrixB) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/matrix/add',
        data: {
          'matrix': matrixA,
          'matrix_b': matrixB,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return MatrixResult(
        operation: 'add',
        matrixA: matrixA,
        matrixB: matrixB,
        result: data['result'] as String,
        steps: data['steps'] as String?,
        latexOutput: data['latex_output'] as String?,
      );
    } catch (e) {
      throw Exception('Matrix addition error: ${e.toString()}');
    }
  }

  @override
  Future<MatrixResult> subtract(String matrixA, String matrixB) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/matrix/add',
        data: {
          'matrix': matrixA,
          'matrix_b': matrixB,
          'operation': 'subtract',
        },
      );
      final data = response.data as Map<String, dynamic>;
      return MatrixResult(
        operation: 'subtract',
        matrixA: matrixA,
        matrixB: matrixB,
        result: data['result'] as String,
        steps: data['steps'] as String?,
        latexOutput: data['latex_output'] as String?,
      );
    } catch (e) {
      throw Exception('Matrix subtraction error: ${e.toString()}');
    }
  }

  @override
  Future<MatrixResult> multiply(String matrixA, String matrixB) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/matrix/multiply',
        data: {
          'matrix': matrixA,
          'matrix_b': matrixB,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return MatrixResult(
        operation: 'multiply',
        matrixA: matrixA,
        matrixB: matrixB,
        result: data['result'] as String,
        steps: data['steps'] as String?,
        latexOutput: data['latex_output'] as String?,
      );
    } catch (e) {
      throw Exception('Matrix multiplication error: ${e.toString()}');
    }
  }

  @override
  Future<MatrixResult> determinant(String matrix) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/matrix/determinant',
        data: {
          'matrix': matrix,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return MatrixResult(
        operation: 'determinant',
        matrixA: matrix,
        result: data['result'] as String,
        steps: data['steps'] as String?,
        latexOutput: data['latex_output'] as String?,
      );
    } catch (e) {
      throw Exception('Matrix determinant error: ${e.toString()}');
    }
  }

  @override
  Future<MatrixResult> inverse(String matrix) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/matrix/inverse',
        data: {
          'matrix': matrix,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return MatrixResult(
        operation: 'inverse',
        matrixA: matrix,
        result: data['result'] as String,
        steps: data['steps'] as String?,
        latexOutput: data['latex_output'] as String?,
      );
    } catch (e) {
      throw Exception('Matrix inverse error: ${e.toString()}');
    }
  }

  @override
  Future<MatrixResult> transpose(String matrix) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/matrix/transpose',
        data: {
          'matrix': matrix,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return MatrixResult(
        operation: 'transpose',
        matrixA: matrix,
        result: data['result'] as String,
        steps: data['steps'] as String?,
        latexOutput: data['latex_output'] as String?,
      );
    } catch (e) {
      throw Exception('Matrix transpose error: ${e.toString()}');
    }
  }
}
