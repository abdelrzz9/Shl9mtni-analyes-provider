package usecase

import (
	"context"

	"github.com/abdelrzz9/math_app/backend/internal/module/calculator/repository"
)

type CalculatorUsecase struct {
	repo repository.CalculatorRepository
}

func NewCalculatorUsecase(repo repository.CalculatorRepository) *CalculatorUsecase {
	return &CalculatorUsecase{repo: repo}
}

type EvaluateResult struct {
	Result float64 `json:"result"`
	Latex  string  `json:"latex"`
}

type ValidateResult struct {
	Valid bool `json:"valid"`
}

func (uc *CalculatorUsecase) Evaluate(ctx context.Context, expression string) (*EvaluateResult, error) {
	result, latex, err := uc.repo.Evaluate(ctx, expression)
	if err != nil {
		return nil, err
	}
	return &EvaluateResult{Result: result, Latex: latex}, nil
}

func (uc *CalculatorUsecase) Validate(ctx context.Context, expression string) (*ValidateResult, error) {
	valid, err := uc.repo.Validate(ctx, expression)
	if err != nil {
		return nil, err
	}
	return &ValidateResult{Valid: valid}, nil
}
