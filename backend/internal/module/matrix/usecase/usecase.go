package usecase

import (
	"fmt"
	"math"
)

type MatrixUsecase struct{}

func NewMatrixUsecase() *MatrixUsecase {
	return &MatrixUsecase{}
}

type Matrix [][]float64

type AddResult struct {
	MatrixA Matrix `json:"matrixA"`
	MatrixB Matrix `json:"matrixB"`
	Result  Matrix `json:"result"`
}

type MultiplyResult struct {
	MatrixA Matrix `json:"matrixA"`
	MatrixB Matrix `json:"matrixB"`
	Result  Matrix `json:"result"`
}

type DeterminantResult struct {
	Matrix     Matrix `json:"matrix"`
	Determinant float64 `json:"determinant"`
}

type InverseResult struct {
	Matrix  Matrix `json:"matrix"`
	Inverse Matrix `json:"inverse"`
}

type TransposeResult struct {
	Matrix    Matrix `json:"matrix"`
	Transpose Matrix `json:"transpose"`
}

func (uc *MatrixUsecase) Add(a, b Matrix) (*AddResult, error) {
	if len(a) == 0 || len(b) == 0 {
		return nil, fmt.Errorf("matrices cannot be empty")
	}
	if len(a) != len(b) || len(a[0]) != len(b[0]) {
		return nil, fmt.Errorf("matrices must have same dimensions for addition")
	}

	rows := len(a)
	cols := len(a[0])
	result := make(Matrix, rows)
	for i := range result {
		result[i] = make([]float64, cols)
		for j := range result[i] {
			result[i][j] = a[i][j] + b[i][j]
		}
	}

	return &AddResult{MatrixA: a, MatrixB: b, Result: result}, nil
}

func (uc *MatrixUsecase) Multiply(a, b Matrix) (*MultiplyResult, error) {
	if len(a) == 0 || len(b) == 0 {
		return nil, fmt.Errorf("matrices cannot be empty")
	}
	if len(a[0]) != len(b) {
		return nil, fmt.Errorf("matrix A columns must equal matrix B rows for multiplication")
	}

	rows := len(a)
	cols := len(b[0])
	common := len(a[0])
	result := make(Matrix, rows)
	for i := range result {
		result[i] = make([]float64, cols)
		for j := range result[i] {
			var sum float64
			for k := 0; k < common; k++ {
				sum += a[i][k] * b[k][j]
			}
			result[i][j] = sum
		}
	}

	return &MultiplyResult{MatrixA: a, MatrixB: b, Result: result}, nil
}

func (uc *MatrixUsecase) Determinant(m Matrix) (*DeterminantResult, error) {
	if len(m) == 0 {
		return nil, fmt.Errorf("matrix cannot be empty")
	}
	if len(m) != len(m[0]) {
		return nil, fmt.Errorf("determinant requires a square matrix")
	}

	det := determinant(m)
	return &DeterminantResult{Matrix: m, Determinant: det}, nil
}

func (uc *MatrixUsecase) Inverse(m Matrix) (*InverseResult, error) {
	if len(m) == 0 {
		return nil, fmt.Errorf("matrix cannot be empty")
	}
	if len(m) != len(m[0]) {
		return nil, fmt.Errorf("inverse requires a square matrix")
	}

	det := determinant(m)
	if math.Abs(det) < 1e-12 {
		return nil, fmt.Errorf("matrix is singular, cannot compute inverse")
	}

	n := len(m)
	inv := make(Matrix, n)
	for i := range inv {
		inv[i] = make([]float64, n)
	}

	adj := adjugate(m)
	for i := 0; i < n; i++ {
		for j := 0; j < n; j++ {
			inv[i][j] = adj[i][j] / det
		}
	}

	return &InverseResult{Matrix: m, Inverse: inv}, nil
}

func (uc *MatrixUsecase) Transpose(m Matrix) (*TransposeResult, error) {
	if len(m) == 0 {
		return nil, fmt.Errorf("matrix cannot be empty")
	}

	rows := len(m)
	cols := len(m[0])
	result := make(Matrix, cols)
	for i := range result {
		result[i] = make([]float64, rows)
		for j := range result[i] {
			result[i][j] = m[j][i]
		}
	}

	return &TransposeResult{Matrix: m, Transpose: result}, nil
}

func copyMatrix(m Matrix) Matrix {
	n := len(m)
	c := make(Matrix, n)
	for i := range c {
		c[i] = make([]float64, len(m[i]))
		copy(c[i], m[i])
	}
	return c
}

func determinant(m Matrix) float64 {
	n := len(m)
	if n == 1 {
		return m[0][0]
	}
	if n == 2 {
		return m[0][0]*m[1][1] - m[0][1]*m[1][0]
	}

	det := 0.0
	for j := 0; j < n; j++ {
		sub := minor(m, 0, j)
		det += math.Pow(-1, float64(j)) * m[0][j] * determinant(sub)
	}
	return det
}

func minor(m Matrix, row, col int) Matrix {
	n := len(m)
	sub := make(Matrix, n-1)
	for i := 0; i < n; i++ {
		if i == row {
			continue
		}
		subRow := make([]float64, 0, n-1)
		for j := 0; j < n; j++ {
			if j == col {
				continue
			}
			subRow = append(subRow, m[i][j])
		}
		subIdx := i
		if i > row {
			subIdx = i - 1
		}
		sub[subIdx] = subRow
	}
	return sub
}

func cofactorMatrix(m Matrix) Matrix {
	n := len(m)
	cof := make(Matrix, n)
	for i := range cof {
		cof[i] = make([]float64, n)
		for j := range cof[i] {
			sub := minor(m, i, j)
			cof[i][j] = math.Pow(-1, float64(i+j)) * determinant(sub)
		}
	}
	return cof
}

func adjugate(m Matrix) Matrix {
	cof := cofactorMatrix(m)
	n := len(m)
	adj := make(Matrix, n)
	for i := range adj {
		adj[i] = make([]float64, n)
		for j := range adj[i] {
			adj[i][j] = cof[j][i]
		}
	}
	return adj
}
