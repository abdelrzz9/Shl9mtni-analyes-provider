import '../entities/integral_result.dart';
import '../repositories/integral_repository.dart';

class IntegrateFunction {
  final IntegralRepository repository;

  IntegrateFunction(this.repository);

  Future<IntegralResult> call(String function, String variable, {String? lowerBound, String? upperBound}) {
    return repository.integrate(function, variable, lowerBound: lowerBound, upperBound: upperBound);
  }
}
