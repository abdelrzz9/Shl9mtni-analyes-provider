import '../entities/limit_result.dart';
import '../repositories/limit_repository.dart';

class EvaluateLimit {
  final LimitRepository repository;

  EvaluateLimit(this.repository);

  Future<LimitResult> call(String function, String variable, String approachPoint, {String? direction}) {
    return repository.evaluateLimit(function, variable, approachPoint, direction: direction);
  }
}
