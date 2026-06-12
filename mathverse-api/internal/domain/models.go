package domain

import (
	"time"
)

const (
	StatusSuccess = "success"
	StatusError   = "error"
	StatusFail    = "fail"
)

type ApiResponse struct {
	Status  string      `json:"status"`
	Message string      `json:"message"`
	Data    interface{} `json:"data,omitempty"`
}

type ErrorResponse struct {
	Code    int         `json:"code"`
	Message string      `json:"message"`
	Details interface{} `json:"details,omitempty"`
}

type HealthResponse struct {
	Status    string            `json:"status"`
	Version   string            `json:"version"`
	Timestamp string            `json:"timestamp"`
	Checks    map[string]string `json:"checks,omitempty"`
}

type PaginatedResponse struct {
	Items      interface{} `json:"items"`
	TotalCount int         `json:"totalCount"`
	Page       int         `json:"page"`
	PageSize   int         `json:"pageSize"`
	TotalPages int         `json:"totalPages"`
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
		Status:  StatusSuccess,
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

func ErrorResponseWithDetails(code int, message string, details interface{}) ErrorResponse {
	return ErrorResponse{
		Code:    code,
		Message: message,
		Details: details,
	}
}
