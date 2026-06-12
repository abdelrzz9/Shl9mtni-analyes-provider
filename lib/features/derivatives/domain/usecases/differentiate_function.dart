import '../entities/derivative_result.dart';
import '../repositories/derivative_repository.dart';

class DifferentiateFunction {
  final DerivativeRepository repository;

  DifferentiateFunction(this.repository);

  Future<DerivativeResult> call(String function, String variable, {int order = 1}) {
    return repository.differentiate(function, variable, order: order);
  }
}
