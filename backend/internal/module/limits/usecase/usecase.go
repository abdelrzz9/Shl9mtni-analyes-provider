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

type LimitUsecase struct {
	mathEngineURL string
	httpClient    *http.Client
}

func NewLimitUsecase(mathEngineURL string) *LimitUsecase {
	return &LimitUsecase{
		mathEngineURL: mathEngineURL,
		httpClient:    &http.Client{},
	}
}

type EvaluateLimitRequest struct {
	Function     string  `json:"function"`
	Variable     string  `json:"variable"`
	ApproachPoint float64 `json:"approachPoint"`
	Direction    string  `json:"direction"`
}

type EvaluateLimitResult struct {
	Function     string  `json:"function"`
	Variable     string  `json:"variable"`
	ApproachPoint float64 `json:"approachPoint"`
	Direction    string  `json:"direction"`
	Result       string  `json:"result"`
}

func (uc *LimitUsecase) Evaluate(ctx context.Context, function, variable string, approachPoint float64, direction string) (*EvaluateLimitResult, error) {
	engineURL, _ := url.JoinPath(uc.mathEngineURL, "/api/v1/limits/evaluate")

	body := EvaluateLimitRequest{
		Function:     function,
		Variable:     variable,
		ApproachPoint: approachPoint,
		Direction:    direction,
	}

	jsonBody, _ := json.Marshal(body)
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, engineURL, bytes.NewReader(jsonBody))
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := uc.httpClient.Do(req)
	if err != nil {
		dir := ""
		switch direction {
		case "left":
			dir = "-"
		case "right":
			dir = "+"
		}
		return &EvaluateLimitResult{
			Function:     function,
			Variable:     variable,
			ApproachPoint: approachPoint,
			Direction:    direction,
			Result:       fmt.Sprintf("lim_{%s \\to %s%s} %s", variable, formatFloat(approachPoint), dir, function),
		}, nil
	}
	defer resp.Body.Close()

	respBody, _ := io.ReadAll(resp.Body)
	var result EvaluateLimitResult
	if err := json.Unmarshal(respBody, &result); err != nil {
		return nil, fmt.Errorf("failed to parse response: %w", err)
	}

	return &result, nil
}

func formatFloat(f float64) string {
	if f == float64(int(f)) {
		return fmt.Sprintf("%d", int(f))
	}
	return fmt.Sprintf("%g", f)
}
