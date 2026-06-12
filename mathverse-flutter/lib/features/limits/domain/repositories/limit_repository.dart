import '../entities/limit_result.dart';

abstract class LimitRepository {
  Future<LimitResult> evaluateLimit(String function, String variable, String approachPoint, {String? direction});
}
