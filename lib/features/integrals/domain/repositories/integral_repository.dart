import '../entities/integral_result.dart';

abstract class IntegralRepository {
  Future<IntegralResult> integrate(String function, String variable, {String? lowerBound, String? upperBound});
}
