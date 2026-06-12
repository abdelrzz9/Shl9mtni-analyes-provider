import '../entities/matrix_result.dart';

abstract class MatrixRepository {
  Future<MatrixResult> add(String matrixA, String matrixB);
  Future<MatrixResult> subtract(String matrixA, String matrixB);
  Future<MatrixResult> multiply(String matrixA, String matrixB);
  Future<MatrixResult> determinant(String matrix);
  Future<MatrixResult> inverse(String matrix);
  Future<MatrixResult> transpose(String matrix);
}
