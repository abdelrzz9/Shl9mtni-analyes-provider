import '../entities/taylor_result.dart';

abstract class TaylorRepository {
  Future<TaylorResult> expand(String function, String variable, String center, int order);
}
