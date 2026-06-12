import '../entities/statistic_result.dart';

abstract class StatisticRepository {
  Future<StatisticResult> mean(List<double> data);
  Future<StatisticResult> median(List<double> data);
  Future<StatisticResult> mode(List<double> data);
  Future<StatisticResult> stdDev(List<double> data);
  Future<StatisticResult> variance(List<double> data);
  Future<StatisticResult> correlation(List<double> data1, List<double> data2);
}
