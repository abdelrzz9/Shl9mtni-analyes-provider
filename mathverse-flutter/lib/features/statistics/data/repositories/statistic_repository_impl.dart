import 'package:mathverse_flutter/core/network/api_client.dart';
import 'package:mathverse_flutter/di/injection_container.dart';

import '../../domain/entities/statistic_result.dart';
import '../../domain/repositories/statistic_repository.dart';

class StatisticRepositoryImpl implements StatisticRepository {
  final ApiClient _apiClient;

  StatisticRepositoryImpl([ApiClient? apiClient]) : _apiClient = apiClient ?? sl();

  @override
  Future<StatisticResult> mean(List<double> data) async {
    return _callStatisticApi(data, 'mean');
  }

  @override
  Future<StatisticResult> median(List<double> data) async {
    return _callStatisticApi(data, 'median');
  }

  @override
  Future<StatisticResult> mode(List<double> data) async {
    return _callStatisticApi(data, 'mode');
  }

  @override
  Future<StatisticResult> stdDev(List<double> data) async {
    return _callStatisticApi(data, 'std_dev');
  }

  @override
  Future<StatisticResult> variance(List<double> data) async {
    return _callStatisticApi(data, 'variance');
  }

  @override
  Future<StatisticResult> correlation(List<double> data1, List<double> data2) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/statistics/calculate',
        data: {
          'data': [...data1, ...data2],
          'operation': 'correlation',
          'data1': data1,
          'data2': data2,
        },
      );
      final resultData = response.data as Map<String, dynamic>;
      return StatisticResult(
        data: '$data1, $data2',
        operation: 'correlation',
        result: resultData['result'].toString(),
        details: resultData['details'] as String?,
        latexOutput: resultData['latex_output'] as String?,
      );
    } catch (e) {
      throw Exception('Correlation calculation error: ${e.toString()}');
    }
  }

  Future<StatisticResult> _callStatisticApi(List<double> data, String operation) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/statistics/calculate',
        data: {
          'data': data,
          'operation': operation,
        },
      );
      final resultData = response.data as Map<String, dynamic>;
      return StatisticResult(
        data: data.toString(),
        operation: operation,
        result: resultData['result'].toString(),
        details: resultData['details'] as String?,
        latexOutput: resultData['latex_output'] as String?,
      );
    } catch (e) {
      throw Exception('$operation calculation error: ${e.toString()}');
    }
  }
}
