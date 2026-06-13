package mathclient

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"
)

type Client struct {
	baseURL string
	http    *http.Client
}

func New(baseURL string, timeout time.Duration) *Client {
	if timeout == 0 {
		timeout = 30 * time.Second
	}
	return &Client{
		baseURL: baseURL,
		http:    &http.Client{Timeout: timeout},
	}
}

func (c *Client) Post(ctx context.Context, endpoint string, body interface{}) (map[string]interface{}, error) {
	jsonBody, err := json.Marshal(body)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal request: %w", err)
	}

	req, err := http.NewRequestWithContext(ctx, http.MethodPost, c.baseURL+endpoint, bytes.NewReader(jsonBody))
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := c.http.Do(req)
	if err != nil {
		return nil, fmt.Errorf("math engine request failed: %w", err)
	}
	defer resp.Body.Close()

	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read response body: %w", err)
	}

	var result map[string]interface{}
	if err := json.Unmarshal(respBody, &result); err != nil {
		return nil, fmt.Errorf("failed to decode response: %w", err)
	}

	if resp.StatusCode >= 400 {
		detail := ""
		if d, ok := result["detail"].(string); ok {
			detail = d
		}
		if detail == "" {
			if d, ok := result["message"].(string); ok {
				detail = d
			}
		}
		if detail == "" {
			detail = fmt.Sprintf("engine returned status %d", resp.StatusCode)
		}
		return result, fmt.Errorf("math engine error: %s", detail)
	}

	return result, nil
}

func ParseFloat64(v interface{}) float64 {
	switch val := v.(type) {
	case float64:
		return val
	case int:
		return float64(val)
	default:
		return 0
	}
}

func ParseInt(v interface{}) int {
	switch val := v.(type) {
	case float64:
		return int(val)
	case int:
		return val
	default:
		return 0
	}
}

func ParseString(v interface{}) string {
	s, _ := v.(string)
	return s
}

func ParseMatrix(v interface{}) [][]float64 {
	raw, ok := v.([]interface{})
	if !ok {
		return nil
	}
	m := make([][]float64, len(raw))
	for i, row := range raw {
		r, ok := row.([]interface{})
		if !ok {
			return nil
		}
		m[i] = make([]float64, len(r))
		for j, val := range r {
			m[i][j] = ParseFloat64(val)
		}
	}
	return m
}

func FormatFloat(f float64) string {
	if f == float64(int(f)) {
		return fmt.Sprintf("%d", int(f))
	}
	return fmt.Sprintf("%g", f)
}
