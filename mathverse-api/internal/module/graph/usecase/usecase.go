package usecase

import (
	"context"
	"fmt"

	"github.com/abdelrzz9/math_app/mathverse-api/internal/pkg/mathclient"
)

type GraphUsecase struct {
	mathClient *mathclient.Client
}

func NewGraphUsecase(mathClient *mathclient.Client) *GraphUsecase {
	return &GraphUsecase{mathClient: mathClient}
}

type Point struct {
	X float64 `json:"x"`
	Y float64 `json:"y"`
}

type PlotResult struct {
	Function string  `json:"function"`
	XMin     float64 `json:"xMin"`
	XMax     float64 `json:"xMax"`
	Step     float64 `json:"step"`
	Points   []Point `json:"points"`
}

func (uc *GraphUsecase) Plot(ctx context.Context, function string, xMin, xMax, step float64) (*PlotResult, error) {
	data, err := uc.mathClient.Post(ctx, "/api/v1/graph/plot", map[string]interface{}{
		"function": function,
		"xMin":     xMin,
		"xMax":     xMax,
		"step":     step,
	})
	if err != nil {
		return nil, fmt.Errorf("plot generation failed: %w", err)
	}
	points := parsePoints(data["points"])
	return &PlotResult{
		Function: mathclient.ParseString(data["function"]),
		XMin:     mathclient.ParseFloat64(data["xMin"]),
		XMax:     mathclient.ParseFloat64(data["xMax"]),
		Step:     mathclient.ParseFloat64(data["step"]),
		Points:   points,
	}, nil
}

func parsePoints(v interface{}) []Point {
	raw, ok := v.([]interface{})
	if !ok {
		return nil
	}
	pts := make([]Point, len(raw))
	for i, item := range raw {
		m, ok := item.(map[string]interface{})
		if !ok {
			continue
		}
		pts[i] = Point{
			X: mathclient.ParseFloat64(m["x"]),
			Y: mathclient.ParseFloat64(m["y"]),
		}
	}
	return pts
}
