package usecase

import (
	"context"
	"fmt"

	"github.com/abdelrzz9/math_app/mathverse-api/internal/pkg/mathclient"
)

type DerivativeUsecase struct {
	mathClient *mathclient.Client
}

func NewDerivativeUsecase(mathClient *mathclient.Client) *DerivativeUsecase {
	return &DerivativeUsecase{mathClient: mathClient}
}

type DifferentiateResult struct {
	Function string `json:"function"`
	Variable string `json:"variable"`
	Order    int    `json:"order"`
	Result   string `json:"result"`
}

func (uc *DerivativeUsecase) Differentiate(ctx context.Context, function, variable string, order int) (*DifferentiateResult, error) {
	data, err := uc.mathClient.Post(ctx, "/api/v1/derivatives/differentiate", map[string]interface{}{
		"function": function,
		"variable": variable,
		"order":    order,
	})
	if err != nil {
		return nil, fmt.Errorf("differentiation failed: %w", err)
	}
	return &DifferentiateResult{
		Function: mathclient.ParseString(data["function"]),
		Variable: mathclient.ParseString(data["variable"]),
		Order:    mathclient.ParseInt(data["order"]),
		Result:   mathclient.ParseString(data["result"]),
	}, nil
}
