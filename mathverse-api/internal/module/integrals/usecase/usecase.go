package usecase

import (
	"context"
	"fmt"

	"github.com/abdelrzz9/math_app/mathverse-api/internal/pkg/mathclient"
)

type IntegralUsecase struct {
	mathClient *mathclient.Client
}

func NewIntegralUsecase(mathClient *mathclient.Client) *IntegralUsecase {
	return &IntegralUsecase{mathClient: mathClient}
}

type IntegrateResult struct {
	Function   string   `json:"function"`
	Variable   string   `json:"variable"`
	LowerBound *float64 `json:"lowerBound,omitempty"`
	UpperBound *float64 `json:"upperBound,omitempty"`
	Result     string   `json:"result"`
}

func (uc *IntegralUsecase) Integrate(ctx context.Context, function, variable string, lowerBound, upperBound *float64) (*IntegrateResult, error) {
	body := map[string]interface{}{
		"function": function,
		"variable": variable,
	}
	if lowerBound != nil {
		body["lowerBound"] = *lowerBound
	}
	if upperBound != nil {
		body["upperBound"] = *upperBound
	}

	data, err := uc.mathClient.Post(ctx, "/api/v1/integrals/integrate", body)
	if err != nil {
		return nil, fmt.Errorf("integration failed: %w", err)
	}
	return &IntegrateResult{
		Function:   mathclient.ParseString(data["function"]),
		Variable:   mathclient.ParseString(data["variable"]),
		LowerBound: lowerBound,
		UpperBound: upperBound,
		Result:     mathclient.ParseString(data["result"]),
	}, nil
}
