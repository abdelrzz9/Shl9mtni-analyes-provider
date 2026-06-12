package handler

import (
	"net/http"

	"github.com/abdelrzz9/math_app/backend/internal/domain"
	"github.com/abdelrzz9/math_app/backend/internal/module/calculator/usecase"
	"github.com/gin-gonic/gin"
)

type CalculatorHandler struct {
	uc *usecase.CalculatorUsecase
}

func NewCalculatorHandler(uc *usecase.CalculatorUsecase) *CalculatorHandler {
	return &CalculatorHandler{uc: uc}
}

type evaluateReq struct {
	Expression string `json:"expression" binding:"required"`
}

type validateReq struct {
	Expression string `json:"expression" binding:"required"`
}

func (h *CalculatorHandler) Evaluate(c *gin.Context) {
	var req evaluateReq
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, domain.ErrorResponseObj(http.StatusBadRequest, "invalid request: "+err.Error()))
		return
	}

	result, err := h.uc.Evaluate(c.Request.Context(), req.Expression)
	if err != nil {
		c.JSON(http.StatusUnprocessableEntity, domain.ErrorResponseObj(http.StatusUnprocessableEntity, err.Error()))
		return
	}

	c.JSON(http.StatusOK, domain.SuccessResponse("evaluation successful", result))
}

func (h *CalculatorHandler) Validate(c *gin.Context) {
	var req validateReq
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, domain.ErrorResponseObj(http.StatusBadRequest, "invalid request: "+err.Error()))
		return
	}

	result, err := h.uc.Validate(c.Request.Context(), req.Expression)
	if err != nil {
		c.JSON(http.StatusInternalServerError, domain.ErrorResponseObj(http.StatusInternalServerError, err.Error()))
		return
	}

	c.JSON(http.StatusOK, domain.SuccessResponse("validation successful", result))
}
