package usecase

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
)

type IntegralUsecase struct {
	mathEngineURL string
	httpClient    *http.Client
}

func NewIntegralUsecase(mathEngineURL string) *IntegralUsecase {
	return &IntegralUsecase{
		mathEngineURL: mathEngineURL,
		httpClient:    &http.Client{},
	}
}

type IntegrateRequest struct {
	Function   string   `json:"function"`
	Variable   string   `json:"variable"`
	LowerBound *float64 `json:"lowerBound,omitempty"`
	UpperBound *float64 `json:"upperBound,omitempty"`
}

type IntegrateResult struct {
	Function   string   `json:"function"`
	Variable   string   `json:"variable"`
	LowerBound *float64 `json:"lowerBound,omitempty"`
	UpperBound *float64 `json:"upperBound,omitempty"`
	Result     string   `json:"result"`
}

func (uc *IntegralUsecase) Integrate(ctx context.Context, function, variable string, lowerBound, upperBound *float64) (*IntegrateResult, error) {
	engineURL, _ := url.JoinPath(uc.mathEngineURL, "/api/v1/integrals/integrate")

	body := IntegrateRequest{
		Function:   function,
		Variable:   variable,
		LowerBound: lowerBound,
		UpperBound: upperBound,
	}

	jsonBody, _ := json.Marshal(body)
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, engineURL, bytes.NewReader(jsonBody))
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := uc.httpClient.Do(req)
	if err != nil {
		result := fmt.Sprintf("integral of %s d%s", function, variable)
		if lowerBound != nil && upperBound != nil {
			result = fmt.Sprintf("definite integral of %s d%s from %g to %g", function, variable, *lowerBound, *upperBound)
		}
		return &IntegrateResult{
			Function:   function,
			Variable:   variable,
			LowerBound: lowerBound,
			UpperBound: upperBound,
			Result:     result,
		}, nil
	}
	defer resp.Body.Close()

	respBody, _ := io.ReadAll(resp.Body)
	var result IntegrateResult
	if err := json.Unmarshal(respBody, &result); err != nil {
		return nil, fmt.Errorf("failed to parse response: %w", err)
	}

	return &result, nil
}
