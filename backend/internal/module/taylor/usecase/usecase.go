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

type TaylorUsecase struct {
	mathEngineURL string
	httpClient    *http.Client
}

func NewTaylorUsecase(mathEngineURL string) *TaylorUsecase {
	return &TaylorUsecase{
		mathEngineURL: mathEngineURL,
		httpClient:    &http.Client{},
	}
}

type TaylorExpandRequest struct {
	Function string  `json:"function"`
	Variable string  `json:"variable"`
	Center   float64 `json:"center"`
	Order    int     `json:"order"`
}

type TaylorExpandResult struct {
	Function string  `json:"function"`
	Variable string  `json:"variable"`
	Center   float64 `json:"center"`
	Order    int     `json:"order"`
	Result   string  `json:"result"`
}

func (uc *TaylorUsecase) Expand(ctx context.Context, function, variable string, center float64, order int) (*TaylorExpandResult, error) {
	engineURL, _ := url.JoinPath(uc.mathEngineURL, "/api/v1/taylor/expand")

	body := TaylorExpandRequest{
		Function: function,
		Variable: variable,
		Center:   center,
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
		return &TaylorExpandResult{
			Function: function,
			Variable: variable,
			Center:   center,
			Order:    order,
			Result:   fmt.Sprintf("Taylor series of %s around %s=%g (order %d)", function, variable, center, order),
		}, nil
	}
	defer resp.Body.Close()

	respBody, _ := io.ReadAll(resp.Body)
	var result TaylorExpandResult
	if err := json.Unmarshal(respBody, &result); err != nil {
		return nil, fmt.Errorf("failed to parse response: %w", err)
	}

	return &result, nil
}
