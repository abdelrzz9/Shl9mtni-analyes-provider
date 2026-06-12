package repository

import "context"

type CalculatorRepository interface {
	Evaluate(ctx context.Context, expression string) (result float64, latex string, err error)
	Validate(ctx context.Context, expression string) (bool, error)
}

type CalculatorServiceImpl struct{}

func NewCalculatorService() CalculatorRepository {
	return &CalculatorServiceImpl{}
}

func (s *CalculatorServiceImpl) Evaluate(ctx context.Context, expression string) (float64, string, error) {
	result, latex, err := evaluateExpression(expression)
	return result, latex, err
}

func (s *CalculatorServiceImpl) Validate(ctx context.Context, expression string) (bool, error) {
	return validateExpression(expression), nil
}
