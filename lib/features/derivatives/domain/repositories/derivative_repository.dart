import '../entities/derivative_result.dart';

abstract class DerivativeRepository {
  Future<DerivativeResult> differentiate(String function, String variable, {int order = 1});
}
