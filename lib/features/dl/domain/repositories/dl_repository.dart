import '../entities/dl_result.dart';

abstract class DLRepository {
  Future<DLResult> expand(String function, String variable, String center, int order);
}
