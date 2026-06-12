package handler

import (
	"net/http"

	"github.com/abdelrzz9/math_app/mathverse-api/internal/domain"
	"github.com/abdelrzz9/math_app/mathverse-api/internal/module/limits/usecase"
	"github.com/gin-gonic/gin"
)

type LimitHandler struct {
	uc *usecase.LimitUsecase
}

func NewLimitHandler(uc *usecase.LimitUsecase) *LimitHandler {
	return &LimitHandler{uc: uc}
}

type evaluateLimitReq struct {
	Function     string  `json:"function" binding:"required"`
	Variable     string  `json:"variable" binding:"required"`
	ApproachPoint float64 `json:"approachPoint"`
	Direction    string  `json:"direction"`
}

func (h *LimitHandler) Evaluate(c *gin.Context) {
	var req evaluateLimitReq
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, domain.ErrorResponseObj(http.StatusBadRequest, "invalid request: "+err.Error()))
		return
	}
	if req.Direction == "" {
		req.Direction = "both"
	}

	result, err := h.uc.Evaluate(c.Request.Context(), req.Function, req.Variable, req.ApproachPoint, req.Direction)
	if err != nil {
		c.JSON(http.StatusUnprocessableEntity, domain.ErrorResponseObj(http.StatusUnprocessableEntity, err.Error()))
		return
	}

	c.JSON(http.StatusOK, domain.SuccessResponse("limit evaluation successful", result))
}
