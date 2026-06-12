package usecase

import (
	"math"
	"testing"
)

func TestMean(t *testing.T) {
	u := &StatisticUsecase{}
	data := []float64{1, 2, 3, 4, 5}
	result, err := u.Calculate(data, "mean")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	expected := 3.0
	if math.Abs(result.Result.(float64)-expected) > 0.001 {
		t.Errorf("expected %f, got %f", expected, result.Result)
	}
}

func TestMedian(t *testing.T) {
	u := &StatisticUsecase{}
	data := []float64{1, 3, 3, 6, 7, 8, 9}
	result, err := u.Calculate(data, "median")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	expected := 6.0
	if math.Abs(result.Result.(float64)-expected) > 0.001 {
		t.Errorf("expected %f, got %f", expected, result.Result)
	}
}

func TestStdDev(t *testing.T) {
	u := &StatisticUsecase{}
	data := []float64{2, 4, 4, 4, 5, 5, 7, 9}
	result, err := u.Calculate(data, "stdDev")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if result.Result.(float64) <= 0 {
		t.Errorf("expected positive std deviation, got %f", result.Result)
	}
}

func TestMin(t *testing.T) {
	u := &StatisticUsecase{}
	data := []float64{3, 1, 4, 1, 5, 9, 2}
	result, err := u.Calculate(data, "min")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if math.Abs(result.Result.(float64)-1.0) > 0.001 {
		t.Errorf("expected 1.0, got %f", result.Result)
	}
}

func TestMax(t *testing.T) {
	u := &StatisticUsecase{}
	data := []float64{3, 1, 4, 1, 5, 9, 2}
	result, err := u.Calculate(data, "max")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if math.Abs(result.Result.(float64)-9.0) > 0.001 {
		t.Errorf("expected 9.0, got %f", result.Result)
	}
}
