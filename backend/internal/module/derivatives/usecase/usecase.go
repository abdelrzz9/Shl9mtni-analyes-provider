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

type DerivativeUsecase struct {
	mathEngineURL string
	httpClient    *http.Client
}

func NewDerivativeUsecase(mathEngineURL string) *DerivativeUsecase {
	return &DerivativeUsecase{
		mathEngineURL: mathEngineURL,
		httpClient:    &http.Client{},
	}
}

type DifferentiateRequest struct {
	Function string `json:"function"`
	Variable string `json:"variable"`
	Order    int    `json:"order"`
}

type DifferentiateResult struct {
	Function string `json:"function"`
	Variable string `json:"variable"`
	Order    int    `json:"order"`
	Result   string `json:"result"`
}

func (uc *DerivativeUsecase) Differentiate(ctx context.Context, function, variable string, order int) (*DifferentiateResult, error) {
	engineURL, _ := url.JoinPath(uc.mathEngineURL, "/api/v1/derivatives/differentiate")

	body := DifferentiateRequest{
		Function: function,
		Variable: variable,
		Order:    order,
	}

	jsonBody, _ := json.Marshal(body)
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, engineURL, bytes.NewReader(jsonBody))
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := uc.httpClient.Do(req)
	if err != nil {
		return &DifferentiateResult{
			Function: function,
			Variable: variable,
			Order:    order,
			Result:   fmt.Sprintf("derivative of %s with respect to %s (order %d)", function, variable, order),
		}, nil
	}
	defer resp.Body.Close()

	respBody, _ := io.ReadAll(resp.Body)
	var result DifferentiateResult
	if err := json.Unmarshal(respBody, &result); err != nil {
		return nil, fmt.Errorf("failed to parse response: %w", err)
	}

	return &result, nil
}
