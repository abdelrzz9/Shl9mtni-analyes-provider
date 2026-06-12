package usecase

import (
	"context"
	"encoding/json"
	"math"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/abdelrzz9/math_app/mathverse-api/internal/pkg/mathclient"
)

func TestMatrixAdd(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(map[string]interface{}{
			"matrixA": [][]float64{{1, 2}, {3, 4}},
			"matrixB": [][]float64{{5, 6}, {7, 8}},
			"result":  [][]float64{{6, 8}, {10, 12}},
		})
	}))
	defer srv.Close()

	u := NewMatrixUsecase(mathclient.New(srv.URL, 5*time.Second))
	a := Matrix{{1, 2}, {3, 4}}
	b := Matrix{{5, 6}, {7, 8}}
	result, err := u.Add(context.Background(), a, b)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if result.Result[0][0] != 6 || result.Result[0][1] != 8 || result.Result[1][0] != 10 || result.Result[1][1] != 12 {
		t.Errorf("unexpected result: %v", result.Result)
	}
}

func TestMatrixMultiply(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(map[string]interface{}{
			"matrixA": [][]float64{{1, 2}, {3, 4}},
			"matrixB": [][]float64{{2, 0}, {1, 2}},
			"result":  [][]float64{{4, 4}, {10, 8}},
		})
	}))
	defer srv.Close()

	u := NewMatrixUsecase(mathclient.New(srv.URL, 5*time.Second))
	a := Matrix{{1, 2}, {3, 4}}
	b := Matrix{{2, 0}, {1, 2}}
	result, err := u.Multiply(context.Background(), a, b)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if result.Result[0][0] != 4 || result.Result[0][1] != 4 || result.Result[1][0] != 10 || result.Result[1][1] != 8 {
		t.Errorf("unexpected result: %v", result.Result)
	}
}

func TestMatrixDeterminant(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(map[string]interface{}{
			"matrix":      [][]float64{{1, 2}, {3, 4}},
			"determinant": -2.0,
		})
	}))
	defer srv.Close()

	u := NewMatrixUsecase(mathclient.New(srv.URL, 5*time.Second))
	a := Matrix{{1, 2}, {3, 4}}
	result, err := u.Determinant(context.Background(), a)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if math.Abs(result.Determinant-(-2.0)) > 0.001 {
		t.Errorf("expected -2.0, got %f", result.Determinant)
	}
}

func TestMatrixInverse(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(map[string]interface{}{
			"matrix":  [][]float64{{4, 7}, {2, 6}},
			"inverse": [][]float64{{0.6, -0.7}, {-0.2, 0.4}},
		})
	}))
	defer srv.Close()

	u := NewMatrixUsecase(mathclient.New(srv.URL, 5*time.Second))
	a := Matrix{{4, 7}, {2, 6}}
	result, err := u.Inverse(context.Background(), a)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if math.Abs(result.Inverse[0][0]-0.6) > 0.01 || math.Abs(result.Inverse[0][1]-(-0.7)) > 0.01 {
		t.Errorf("unexpected result: %v", result.Inverse)
	}
}

func TestMatrixTranspose(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(map[string]interface{}{
			"matrix":    [][]float64{{1, 2, 3}, {4, 5, 6}},
			"transpose": [][]float64{{1, 4}, {2, 5}, {3, 6}},
		})
	}))
	defer srv.Close()

	u := NewMatrixUsecase(mathclient.New(srv.URL, 5*time.Second))
	a := Matrix{{1, 2, 3}, {4, 5, 6}}
	result, err := u.Transpose(context.Background(), a)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if len(result.Transpose) != 3 || len(result.Transpose[0]) != 2 {
		t.Errorf("expected 3x2 matrix, got %dx%d", len(result.Transpose), len(result.Transpose[0]))
	}
}
