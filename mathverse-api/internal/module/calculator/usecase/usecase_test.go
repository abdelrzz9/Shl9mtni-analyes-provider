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

func TestCalculatorEvaluate(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(map[string]interface{}{
			"result": 42.0,
			"latex":  "42",
		})
	}))
	defer srv.Close()

	uc := NewCalculatorUsecase(mathclient.New(srv.URL, 5*time.Second))
	result, err := uc.Evaluate(context.Background(), "6 * 7")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if math.Abs(result.Result-42.0) > 0.001 {
		t.Errorf("expected 42.0, got %f", result.Result)
	}
	if result.Latex != "42" {
		t.Errorf("expected latex '42', got '%s'", result.Latex)
	}
}

func TestCalculatorEvaluate_ZeroResult(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(map[string]interface{}{
			"result": 0.0,
			"latex":  "0",
		})
	}))
	defer srv.Close()

	uc := NewCalculatorUsecase(mathclient.New(srv.URL, 5*time.Second))
	result, err := uc.Evaluate(context.Background(), "0")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if math.Abs(result.Result-0.0) > 0.001 {
		t.Errorf("expected 0.0, got %f", result.Result)
	}
}

func TestCalculatorEvaluate_NegativeResult(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(map[string]interface{}{
			"result": -5.0,
			"latex":  "-5",
		})
	}))
	defer srv.Close()

	uc := NewCalculatorUsecase(mathclient.New(srv.URL, 5*time.Second))
	result, err := uc.Evaluate(context.Background(), "-5")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if math.Abs(result.Result+5.0) > 0.001 {
		t.Errorf("expected -5.0, got %f", result.Result)
	}
}

func TestCalculatorValidate_ValidExpression(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(map[string]interface{}{
			"valid": true,
		})
	}))
	defer srv.Close()

	uc := NewCalculatorUsecase(mathclient.New(srv.URL, 5*time.Second))
	result, err := uc.Validate(context.Background(), "2+2")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if !result.Valid {
		t.Error("expected valid=true")
	}
}

func TestCalculatorValidate_InvalidExpression(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(map[string]interface{}{
			"valid": false,
		})
	}))
	defer srv.Close()

	uc := NewCalculatorUsecase(mathclient.New(srv.URL, 5*time.Second))
	result, err := uc.Validate(context.Background(), "invalid@@")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if result.Valid {
		t.Error("expected valid=false")
	}
}

func TestCalculatorEvaluate_EngineError(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusUnprocessableEntity)
		json.NewEncoder(w).Encode(map[string]interface{}{
			"error": "invalid expression",
		})
	}))
	defer srv.Close()

	uc := NewCalculatorUsecase(mathclient.New(srv.URL, 5*time.Second))
	_, err := uc.Evaluate(context.Background(), "invalid")
	if err == nil {
		t.Fatal("expected error, got nil")
	}
}

func TestCalculatorEvaluate_DifferentOperations(t *testing.T) {
	tests := []struct {
		name       string
		expression string
		expected   float64
		latex      string
	}{
		{"addition", "1+1", 2.0, "2"},
		{"subtraction", "5-3", 2.0, "2"},
		{"multiplication", "4*5", 20.0, "20"},
		{"division", "10/2", 5.0, "5"},
		{"power", "2^3", 8.0, "8"},
		{"sqrt", "sqrt(9)", 3.0, "3"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				w.WriteHeader(http.StatusOK)
				json.NewEncoder(w).Encode(map[string]interface{}{
					"result": tt.expected,
					"latex":  tt.latex,
				})
			}))
			defer srv.Close()

			uc := NewCalculatorUsecase(mathclient.New(srv.URL, 5*time.Second))
			result, err := uc.Evaluate(context.Background(), tt.expression)
			if err != nil {
				t.Fatalf("unexpected error: %v", err)
			}
			if math.Abs(result.Result-tt.expected) > 0.001 {
				t.Errorf("expected %f, got %f", tt.expected, result.Result)
			}
		})
	}
}
