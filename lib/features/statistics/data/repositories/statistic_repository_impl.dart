import 'dart:math';

import '../../domain/entities/statistic_result.dart';
import '../../domain/repositories/statistic_repository.dart';

class StatisticRepositoryImpl implements StatisticRepository {
  @override
  Future<StatisticResult> mean(List<double> data) async {
    final result = data.reduce((a, b) => a + b) / data.length;
    return StatisticResult(
      data: data.toString(),
      operation: 'mean',
      result: result.toString(),
      details: 'Sum = ${data.reduce((a, b) => a + b)}, n = ${data.length}',
    );
  }

  @override
  Future<StatisticResult> median(List<double> data) async {
    final sorted = List<double>.from(data)..sort();
    double result;
    if (sorted.length.isOdd) {
      result = sorted[sorted.length ~/ 2];
    } else {
      final mid = sorted.length ~/ 2;
      result = (sorted[mid - 1] + sorted[mid]) / 2;
    }
    return StatisticResult(
      data: data.toString(),
      operation: 'median',
      result: result.toString(),
    );
  }

  @override
  Future<StatisticResult> mode(List<double> data) async {
    final frequencies = <double, int>{};
    for (final value in data) {
      frequencies[value] = (frequencies[value] ?? 0) + 1;
    }
    final maxFreq = frequencies.values.reduce(max);
    final modes = frequencies.entries
        .where((e) => e.value == maxFreq)
        .map((e) => e.key)
        .toList();
    return StatisticResult(
      data: data.toString(),
      operation: 'mode',
      result: modes.toString(),
      details: 'Frequency: $maxFreq',
    );
  }

  @override
  Future<StatisticResult> stdDev(List<double> data) async {
    final meanVal = data.reduce((a, b) => a + b) / data.length;
    final squaredDiff = data.map((x) => (x - meanVal) * (x - meanVal)).reduce((a, b) => a + b);
    final result = sqrt(squaredDiff / data.length);
    return StatisticResult(
      data: data.toString(),
      operation: 'stdDev',
      result: result.toString(),
      details: 'Variance: ${squaredDiff / data.length}',
    );
  }

  @override
  Future<StatisticResult> variance(List<double> data) async {
    final meanVal = data.reduce((a, b) => a + b) / data.length;
    final squaredDiff = data.map((x) => (x - meanVal) * (x - meanVal)).reduce((a, b) => a + b);
    final result = squaredDiff / data.length;
    return StatisticResult(
      data: data.toString(),
      operation: 'variance',
      result: result.toString(),
    );
  }

  @override
  Future<StatisticResult> correlation(List<double> data1, List<double> data2) async {
    if (data1.length != data2.length) {
      return StatisticResult(
        data: '$data1, $data2',
        operation: 'correlation',
        result: 'Error: Data sets must have same length',
      );
    }
    final n = data1.length;
    final mean1 = data1.reduce((a, b) => a + b) / n;
    final mean2 = data2.reduce((a, b) => a + b) / n;
    double cov = 0, var1 = 0, var2 = 0;
    for (var i = 0; i < n; i++) {
      final d1 = data1[i] - mean1;
      final d2 = data2[i] - mean2;
      cov += d1 * d2;
      var1 += d1 * d1;
      var2 += d2 * d2;
    }
    final result = cov / sqrt(var1 * var2);
    return StatisticResult(
      data: '$data1, $data2',
      operation: 'correlation',
      result: result.toString(),
      details: 'Covariance: ${cov / n}',
    );
  }
}
