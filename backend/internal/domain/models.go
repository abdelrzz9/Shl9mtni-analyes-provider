package domain

import "time"

type ApiResponse struct {
	Status  string      `json:"status"`
	Message string      `json:"message"`
	Data    interface{} `json:"data,omitempty"`
}

type ErrorResponse struct {
	Code    int    `json:"code"`
	Message string `json:"message"`
}

type HealthResponse struct {
	Status    string `json:"status"`
	Version   string `json:"version"`
	Timestamp string `json:"timestamp"`
}

func NewHealthResponse() HealthResponse {
	return HealthResponse{
		Status:    "ok",
		Version:   "1.0.0",
		Timestamp: time.Now().UTC().Format(time.RFC3339),
	}
}

func SuccessResponse(message string, data interface{}) ApiResponse {
	return ApiResponse{
		Status:  "success",
		Message: message,
		Data:    data,
	}
}

func ErrorResponseObj(code int, message string) ErrorResponse {
	return ErrorResponse{
		Code:    code,
		Message: message,
	}
}
