package usecase

import (
	"fmt"
	"math"
	"sort"
)

type StatisticUsecase struct{}

func NewStatisticUsecase() *StatisticUsecase {
	return &StatisticUsecase{}
}

type CalculateRequest struct {
	Data      []float64 `json:"data"`
	Operation string    `json:"operation"`
}

type CalculateResult struct {
	Operation string      `json:"operation"`
	Data      []float64   `json:"data"`
	Result    interface{} `json:"result"`
}

func (uc *StatisticUsecase) Calculate(data []float64, operation string) (*CalculateResult, error) {
	if len(data) == 0 {
		return nil, fmt.Errorf("data slice cannot be empty")
	}

	var result interface{}
	var err error

	switch operation {
	case "mean":
		result = mean(data)
	case "median":
		result = median(data)
	case "mode":
		result = mode(data)
	case "stdDev":
		result = stdDev(data)
	case "variance":
		result = variance(data)
	case "min":
		result = minVal(data)
	case "max":
		result = maxVal(data)
	case "sum":
		result = sum(data)
	default:
		return nil, fmt.Errorf("unknown operation: %s", operation)
	}

	if err != nil {
		return nil, err
	}

	return &CalculateResult{
		Operation: operation,
		Data:      data,
		Result:    result,
	}, nil
}

func mean(data []float64) float64 {
	return sum(data) / float64(len(data))
}

func median(data []float64) float64 {
	sorted := make([]float64, len(data))
	copy(sorted, data)
	sort.Float64s(sorted)

	n := len(sorted)
	if n%2 == 0 {
		return (sorted[n/2-1] + sorted[n/2]) / 2.0
	}
	return sorted[n/2]
}

func mode(data []float64) []float64 {
	freq := make(map[float64]int)
	for _, v := range data {
		freq[v]++
	}

	maxFreq := 0
	for _, f := range freq {
		if f > maxFreq {
			maxFreq = f
		}
	}

	if maxFreq <= 1 {
		return nil
	}

	var modes []float64
	for v, f := range freq {
		if f == maxFreq {
			modes = append(modes, v)
		}
	}

	sort.Float64s(modes)
	return modes
}

func stdDev(data []float64) float64 {
	return math.Sqrt(variance(data))
}

func variance(data []float64) float64 {
	m := mean(data)
	var sumSq float64
	for _, v := range data {
		diff := v - m
		sumSq += diff * diff
	}
	return sumSq / float64(len(data))
}

func minVal(data []float64) float64 {
	min := data[0]
	for _, v := range data[1:] {
		if v < min {
			min = v
		}
	}
	return min
}

func maxVal(data []float64) float64 {
	max := data[0]
	for _, v := range data[1:] {
		if v > max {
			max = v
		}
	}
	return max
}

func sum(data []float64) float64 {
	var s float64
	for _, v := range data {
		s += v
	}
	return s
}
