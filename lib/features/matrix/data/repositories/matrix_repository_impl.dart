import '../../domain/entities/matrix_result.dart';
import '../../domain/repositories/matrix_repository.dart';

class MatrixRepositoryImpl implements MatrixRepository {
  @override
  Future<MatrixResult> add(String matrixA, String matrixB) async {
    final result = _localAdd(matrixA, matrixB);
    return MatrixResult(
      operation: 'add',
      matrixA: matrixA,
      matrixB: matrixB,
      result: result,
    );
  }

  @override
  Future<MatrixResult> subtract(String matrixA, String matrixB) async {
    final result = _localSubtract(matrixA, matrixB);
    return MatrixResult(
      operation: 'subtract',
      matrixA: matrixA,
      matrixB: matrixB,
      result: result,
    );
  }

  @override
  Future<MatrixResult> multiply(String matrixA, String matrixB) async {
    final result = _localMultiply(matrixA, matrixB);
    return MatrixResult(
      operation: 'multiply',
      matrixA: matrixA,
      matrixB: matrixB,
      result: result,
    );
  }

  @override
  Future<MatrixResult> determinant(String matrix) async {
    final result = _localDeterminant(matrix);
    return MatrixResult(
      operation: 'determinant',
      matrixA: matrix,
      result: result,
    );
  }

  @override
  Future<MatrixResult> inverse(String matrix) async {
    final result = _localInverse(matrix);
    return MatrixResult(
      operation: 'inverse',
      matrixA: matrix,
      result: result,
    );
  }

  @override
  Future<MatrixResult> transpose(String matrix) async {
    final result = _localTranspose(matrix);
    return MatrixResult(
      operation: 'transpose',
      matrixA: matrix,
      result: result,
    );
  }

  List<List<double>> _parseMatrix(String matrixStr) {
    final cleaned = matrixStr.replaceAll(' ', '');
    final rows = cleaned.split(';');
    return rows.map((row) {
      return row.split(',').map((e) => double.tryParse(e) ?? 0.0).toList();
    }).toList();
  }

  String _formatMatrix(List<List<double>> matrix) {
    return matrix.map((row) => row.map((e) => e.toString()).join(', ')).join('; ');
  }

  String _localAdd(String matrixA, String matrixB) {
    final a = _parseMatrix(matrixA);
    final b = _parseMatrix(matrixB);
    if (a.length != b.length || a[0].length != b[0].length) {
      return 'Error: Matrices must have same dimensions';
    }
    final result = List.generate(a.length, (i) => List.generate(a[0].length, (j) => a[i][j] + b[i][j]));
    return _formatMatrix(result);
  }

  String _localSubtract(String matrixA, String matrixB) {
    final a = _parseMatrix(matrixA);
    final b = _parseMatrix(matrixB);
    if (a.length != b.length || a[0].length != b[0].length) {
      return 'Error: Matrices must have same dimensions';
    }
    final result = List.generate(a.length, (i) => List.generate(a[0].length, (j) => a[i][j] - b[i][j]));
    return _formatMatrix(result);
  }

  String _localMultiply(String matrixA, String matrixB) {
    final a = _parseMatrix(matrixA);
    final b = _parseMatrix(matrixB);
    if (a[0].length != b.length) {
      return 'Error: Invalid dimensions for multiplication';
    }
    final result = List.generate(a.length, (i) => List.generate(b[0].length, (j) {
      double sum = 0;
      for (var k = 0; k < a[0].length; k++) {
        sum += a[i][k] * b[k][j];
      }
      return sum;
    }));
    return _formatMatrix(result);
  }

  String _localDeterminant(String matrix) {
    final a = _parseMatrix(matrix);
    if (a.length != a[0].length) return 'Error: Matrix must be square';
    if (a.length == 2) {
      final det = a[0][0] * a[1][1] - a[0][1] * a[1][0];
      return det.toString();
    }
    if (a.length == 3) {
      final det = a[0][0] * (a[1][1] * a[2][2] - a[1][2] * a[2][1]) -
          a[0][1] * (a[1][0] * a[2][2] - a[1][2] * a[2][0]) +
          a[0][2] * (a[1][0] * a[2][1] - a[1][1] * a[2][0]);
      return det.toString();
    }
    return 'See math engine for detailed result';
  }

  String _localInverse(String matrix) {
    final a = _parseMatrix(matrix);
    if (a.length != a[0].length) return 'Error: Matrix must be square';
    if (a.length == 2) {
      final det = a[0][0] * a[1][1] - a[0][1] * a[1][0];
      if (det == 0) return 'Error: Matrix is singular';
      final inv = [
        [a[1][1] / det, -a[0][1] / det],
        [-a[1][0] / det, a[0][0] / det],
      ];
      return _formatMatrix(inv);
    }
    return 'See math engine for detailed result';
  }

  String _localTranspose(String matrix) {
    final a = _parseMatrix(matrix);
    final result = List.generate(a[0].length, (i) => List.generate(a.length, (j) => a[j][i]));
    return _formatMatrix(result);
  }
}
