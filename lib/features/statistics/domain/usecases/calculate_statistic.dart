import '../entities/statistic_result.dart';
import '../repositories/statistic_repository.dart';

class CalculateStatistic {
  final StatisticRepository repository;

  CalculateStatistic(this.repository);

  Future<StatisticResult> call({
    required String operation,
    required List<double> data,
    List<double>? data2,
  }) {
    switch (operation) {
      case 'mean':
        return repository.mean(data);
      case 'median':
        return repository.median(data);
      case 'mode':
        return repository.mode(data);
      case 'stdDev':
        return repository.stdDev(data);
      case 'variance':
        return repository.variance(data);
      case 'correlation':
        return repository.correlation(data, data2 ?? []);
      default:
        throw ArgumentError('Unknown operation: $operation');
    }
  }
}
