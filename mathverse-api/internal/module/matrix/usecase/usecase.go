package usecase

import (
	"context"
	"fmt"

	"github.com/abdelrzz9/math_app/mathverse-api/internal/pkg/mathclient"
)

type MatrixUsecase struct {
	mathClient *mathclient.Client
}

func NewMatrixUsecase(mathClient *mathclient.Client) *MatrixUsecase {
	return &MatrixUsecase{mathClient: mathClient}
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
	Matrix      Matrix  `json:"matrix"`
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

func (uc *MatrixUsecase) Add(ctx context.Context, a, b Matrix) (*AddResult, error) {
	data, err := uc.mathClient.Post(ctx, "/api/v1/matrix/add", map[string]interface{}{
		"matrixA": a,
		"matrixB": b,
	})
	if err != nil {
		return nil, fmt.Errorf("matrix addition failed: %w", err)
	}
	return &AddResult{
		MatrixA: mathclient.ParseMatrix(data["matrixA"]),
		MatrixB: mathclient.ParseMatrix(data["matrixB"]),
		Result:  mathclient.ParseMatrix(data["result"]),
	}, nil
}

func (uc *MatrixUsecase) Multiply(ctx context.Context, a, b Matrix) (*MultiplyResult, error) {
	data, err := uc.mathClient.Post(ctx, "/api/v1/matrix/multiply", map[string]interface{}{
		"matrixA": a,
		"matrixB": b,
	})
	if err != nil {
		return nil, fmt.Errorf("matrix multiplication failed: %w", err)
	}
	return &MultiplyResult{
		MatrixA: mathclient.ParseMatrix(data["matrixA"]),
		MatrixB: mathclient.ParseMatrix(data["matrixB"]),
		Result:  mathclient.ParseMatrix(data["result"]),
	}, nil
}

func (uc *MatrixUsecase) Determinant(ctx context.Context, m Matrix) (*DeterminantResult, error) {
	data, err := uc.mathClient.Post(ctx, "/api/v1/matrix/determinant", map[string]interface{}{
		"matrix": m,
	})
	if err != nil {
		return nil, fmt.Errorf("determinant calculation failed: %w", err)
	}
	return &DeterminantResult{
		Matrix:      mathclient.ParseMatrix(data["matrix"]),
		Determinant: mathclient.ParseFloat64(data["determinant"]),
	}, nil
}

func (uc *MatrixUsecase) Inverse(ctx context.Context, m Matrix) (*InverseResult, error) {
	data, err := uc.mathClient.Post(ctx, "/api/v1/matrix/inverse", map[string]interface{}{
		"matrix": m,
	})
	if err != nil {
		return nil, fmt.Errorf("matrix inverse failed: %w", err)
	}
	return &InverseResult{
		Matrix:  mathclient.ParseMatrix(data["matrix"]),
		Inverse: mathclient.ParseMatrix(data["inverse"]),
	}, nil
}

func (uc *MatrixUsecase) Transpose(ctx context.Context, m Matrix) (*TransposeResult, error) {
	data, err := uc.mathClient.Post(ctx, "/api/v1/matrix/transpose", map[string]interface{}{
		"matrix": m,
	})
	if err != nil {
		return nil, fmt.Errorf("matrix transpose failed: %w", err)
	}
	return &TransposeResult{
		Matrix:    mathclient.ParseMatrix(data["matrix"]),
		Transpose: mathclient.ParseMatrix(data["transpose"]),
	}, nil
}
