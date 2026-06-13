package usecase

import (
	"context"

	"github.com/abdelrzz9/math_app/mathverse-api/internal/pkg/mathclient"
)

type CalculatorUsecase struct {
	mathClient *mathclient.Client
}

func NewCalculatorUsecase(mathClient *mathclient.Client) *CalculatorUsecase {
	return &CalculatorUsecase{mathClient: mathClient}
}

type EvaluateResult struct {
	Result float64 `json:"result"`
	Latex  string  `json:"latex"`
}

type ValidateResult struct {
	Valid bool `json:"valid"`
}

func (uc *CalculatorUsecase) Evaluate(ctx context.Context, expression string) (*EvaluateResult, error) {
	data, err := uc.mathClient.Post(ctx, "/api/v1/calculator/evaluate", map[string]interface{}{
		"expression": expression,
	})
	if err != nil {
		return nil, err
	}
	result, _ := data["result"].(float64)
	latex, _ := data["latex"].(string)
	return &EvaluateResult{Result: result, Latex: latex}, nil
}

func (uc *CalculatorUsecase) Validate(ctx context.Context, expression string) (*ValidateResult, error) {
	data, err := uc.mathClient.Post(ctx, "/api/v1/calculator/validate", map[string]interface{}{
		"expression": expression,
	})
	if err != nil {
		return nil, err
	}
	valid, _ := data["valid"].(bool)
	return &ValidateResult{Valid: valid}, nil
}
