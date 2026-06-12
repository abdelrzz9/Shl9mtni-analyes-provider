package usecase

import (
	"context"
	"fmt"

	"github.com/abdelrzz9/math_app/mathverse-api/internal/pkg/mathclient"
)

type TaylorUsecase struct {
	mathClient *mathclient.Client
}

func NewTaylorUsecase(mathClient *mathclient.Client) *TaylorUsecase {
	return &TaylorUsecase{mathClient: mathClient}
}

type TaylorExpandResult struct {
	Function string  `json:"function"`
	Variable string  `json:"variable"`
	Center   float64 `json:"center"`
	Order    int     `json:"order"`
	Result   string  `json:"result"`
}

func (uc *TaylorUsecase) Expand(ctx context.Context, function, variable string, center float64, order int) (*TaylorExpandResult, error) {
	data, err := uc.mathClient.Post(ctx, "/api/v1/taylor/expand", map[string]interface{}{
		"function": function,
		"variable": variable,
		"center":   center,
		"order":    order,
	})
	if err != nil {
		return nil, fmt.Errorf("taylor expansion failed: %w", err)
	}
	return &TaylorExpandResult{
		Function: mathclient.ParseString(data["function"]),
		Variable: mathclient.ParseString(data["variable"]),
		Center:   mathclient.ParseFloat64(data["center"]),
		Order:    mathclient.ParseInt(data["order"]),
		Result:   mathclient.ParseString(data["result"]),
	}, nil
}
