import '../entities/dl_result.dart';
import '../repositories/dl_repository.dart';

class ExpandDL {
  final DLRepository repository;

  ExpandDL(this.repository);

  Future<DLResult> call(String function, String variable, String center, int order) {
    return repository.expand(function, variable, center, order);
  }
}
