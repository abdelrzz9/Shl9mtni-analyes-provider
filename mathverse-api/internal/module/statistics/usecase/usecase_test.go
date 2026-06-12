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

func TestMean(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(map[string]interface{}{
			"operation": "mean",
			"result":    3.0,
		})
	}))
	defer srv.Close()

	u := NewStatisticUsecase(mathclient.New(srv.URL, 5*time.Second))
	data := []float64{1, 2, 3, 4, 5}
	result, err := u.Calculate(context.Background(), data, "mean")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	expected := 3.0
	if math.Abs(result.Result.(float64)-expected) > 0.001 {
		t.Errorf("expected %f, got %f", expected, result.Result)
	}
}

func TestMedian(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(map[string]interface{}{
			"operation": "median",
			"result":    6.0,
		})
	}))
	defer srv.Close()

	u := NewStatisticUsecase(mathclient.New(srv.URL, 5*time.Second))
	data := []float64{1, 3, 3, 6, 7, 8, 9}
	result, err := u.Calculate(context.Background(), data, "median")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	expected := 6.0
	if math.Abs(result.Result.(float64)-expected) > 0.001 {
		t.Errorf("expected %f, got %f", expected, result.Result)
	}
}

func TestStdDev(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(map[string]interface{}{
			"operation": "stdDev",
			"result":    2.0,
		})
	}))
	defer srv.Close()

	u := NewStatisticUsecase(mathclient.New(srv.URL, 5*time.Second))
	data := []float64{2, 4, 4, 4, 5, 5, 7, 9}
	result, err := u.Calculate(context.Background(), data, "stdDev")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if result.Result.(float64) <= 0 {
		t.Errorf("expected positive std deviation, got %f", result.Result)
	}
}

func TestMin(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(map[string]interface{}{
			"operation": "min",
			"result":    1.0,
		})
	}))
	defer srv.Close()

	u := NewStatisticUsecase(mathclient.New(srv.URL, 5*time.Second))
	data := []float64{3, 1, 4, 1, 5, 9, 2}
	result, err := u.Calculate(context.Background(), data, "min")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if math.Abs(result.Result.(float64)-1.0) > 0.001 {
		t.Errorf("expected 1.0, got %f", result.Result)
	}
}

func TestMax(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(map[string]interface{}{
			"operation": "max",
			"result":    9.0,
		})
	}))
	defer srv.Close()

	u := NewStatisticUsecase(mathclient.New(srv.URL, 5*time.Second))
	data := []float64{3, 1, 4, 1, 5, 9, 2}
	result, err := u.Calculate(context.Background(), data, "max")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if math.Abs(result.Result.(float64)-9.0) > 0.001 {
		t.Errorf("expected 9.0, got %f", result.Result)
	}
}
