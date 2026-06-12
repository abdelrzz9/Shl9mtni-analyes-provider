package usecase

import (
	"math"
	"testing"
)

func TestMatrixAdd(t *testing.T) {
	u := &MatrixUsecase{}
	a := Matrix{{1, 2}, {3, 4}}
	b := Matrix{{5, 6}, {7, 8}}
	result, err := u.Add(a, b)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if result.Result[0][0] != 6 || result.Result[0][1] != 8 || result.Result[1][0] != 10 || result.Result[1][1] != 12 {
		t.Errorf("unexpected result: %v", result.Result)
	}
}

func TestMatrixMultiply(t *testing.T) {
	u := &MatrixUsecase{}
	a := Matrix{{1, 2}, {3, 4}}
	b := Matrix{{2, 0}, {1, 2}}
	result, err := u.Multiply(a, b)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if result.Result[0][0] != 4 || result.Result[0][1] != 4 || result.Result[1][0] != 10 || result.Result[1][1] != 8 {
		t.Errorf("unexpected result: %v", result.Result)
	}
}

func TestMatrixDeterminant(t *testing.T) {
	u := &MatrixUsecase{}
	a := Matrix{{1, 2}, {3, 4}}
	result, err := u.Determinant(a)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if math.Abs(result.Determinant-(-2.0)) > 0.001 {
		t.Errorf("expected -2.0, got %f", result.Determinant)
	}
}

func TestMatrixInverse(t *testing.T) {
	u := &MatrixUsecase{}
	a := Matrix{{4, 7}, {2, 6}}
	result, err := u.Inverse(a)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if math.Abs(result.Inverse[0][0]-0.6) > 0.01 || math.Abs(result.Inverse[0][1]-(-0.7)) > 0.01 {
		t.Errorf("unexpected result: %v", result.Inverse)
	}
}

func TestMatrixTranspose(t *testing.T) {
	u := &MatrixUsecase{}
	a := Matrix{{1, 2, 3}, {4, 5, 6}}
	result, err := u.Transpose(a)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if len(result.Transpose) != 3 || len(result.Transpose[0]) != 2 {
		t.Errorf("expected 3x2 matrix, got %dx%d", len(result.Transpose), len(result.Transpose[0]))
	}
}
