package usecase

import (
	"context"
	"fmt"

	"github.com/abdelrzz9/math_app/mathverse-api/internal/pkg/mathclient"
)

type StatisticUsecase struct {
	mathClient *mathclient.Client
}

func NewStatisticUsecase(mathClient *mathclient.Client) *StatisticUsecase {
	return &StatisticUsecase{mathClient: mathClient}
}

type CalculateResult struct {
	Operation string      `json:"operation"`
	Data      []float64   `json:"data"`
	Result    interface{} `json:"result"`
}

func (uc *StatisticUsecase) Calculate(ctx context.Context, data []float64, operation string) (*CalculateResult, error) {
	raw, err := uc.mathClient.Post(ctx, "/api/v1/statistics/calculate", map[string]interface{}{
		"data":      data,
		"operation": operation,
	})
	if err != nil {
		return nil, fmt.Errorf("statistical calculation failed: %w", err)
	}
	return &CalculateResult{
		Operation: mathclient.ParseString(raw["operation"]),
		Data:      data,
		Result:    raw["result"],
	}, nil
}
