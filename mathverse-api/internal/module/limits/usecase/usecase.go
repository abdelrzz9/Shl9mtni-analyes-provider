package usecase

import (
	"context"
	"fmt"

	"github.com/abdelrzz9/math_app/mathverse-api/internal/pkg/mathclient"
)

type LimitUsecase struct {
	mathClient *mathclient.Client
}

func NewLimitUsecase(mathClient *mathclient.Client) *LimitUsecase {
	return &LimitUsecase{mathClient: mathClient}
}

type EvaluateLimitResult struct {
	Function      string  `json:"function"`
	Variable      string  `json:"variable"`
	ApproachPoint float64 `json:"approachPoint"`
	Direction     string  `json:"direction"`
	Result        string  `json:"result"`
}

func (uc *LimitUsecase) Evaluate(ctx context.Context, function, variable string, approachPoint float64, direction string) (*EvaluateLimitResult, error) {
	data, err := uc.mathClient.Post(ctx, "/api/v1/limits/evaluate", map[string]interface{}{
		"function":      function,
		"variable":      variable,
		"approachPoint": approachPoint,
		"direction":     direction,
	})
	if err != nil {
		return nil, fmt.Errorf("limit evaluation failed: %w", err)
	}
	return &EvaluateLimitResult{
		Function:      mathclient.ParseString(data["function"]),
		Variable:      mathclient.ParseString(data["variable"]),
		ApproachPoint: mathclient.ParseFloat64(data["approachPoint"]),
		Direction:     mathclient.ParseString(data["direction"]),
		Result:        mathclient.ParseString(data["result"]),
	}, nil
}
