import '../entities/matrix_result.dart';
import '../repositories/matrix_repository.dart';

class MatrixOperation {
  final MatrixRepository repository;

  MatrixOperation(this.repository);

  Future<MatrixResult> call({
    required String operation,
    required String matrixA,
    String? matrixB,
  }) {
    switch (operation) {
      case 'add':
        return repository.add(matrixA, matrixB ?? '');
      case 'subtract':
        return repository.subtract(matrixA, matrixB ?? '');
      case 'multiply':
        return repository.multiply(matrixA, matrixB ?? '');
      case 'determinant':
        return repository.determinant(matrixA);
      case 'inverse':
        return repository.inverse(matrixA);
      case 'transpose':
        return repository.transpose(matrixA);
      default:
        throw ArgumentError('Unknown operation: $operation');
    }
  }
}
