import '../entities/taylor_result.dart';
import '../repositories/taylor_repository.dart';

class ExpandTaylorSeries {
  final TaylorRepository repository;

  ExpandTaylorSeries(this.repository);

  Future<TaylorResult> call(String function, String variable, String center, int order) {
    return repository.expand(function, variable, center, order);
  }
}
