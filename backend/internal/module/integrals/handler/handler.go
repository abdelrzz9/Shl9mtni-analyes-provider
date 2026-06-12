package handler

import (
	"net/http"

	"github.com/abdelrzz9/math_app/backend/internal/domain"
	"github.com/abdelrzz9/math_app/backend/internal/module/integrals/usecase"
	"github.com/gin-gonic/gin"
)

type IntegralHandler struct {
	uc *usecase.IntegralUsecase
}

func NewIntegralHandler(uc *usecase.IntegralUsecase) *IntegralHandler {
	return &IntegralHandler{uc: uc}
}

type integrateReq struct {
	Function   string   `json:"function" binding:"required"`
	Variable   string   `json:"variable" binding:"required"`
	LowerBound *float64 `json:"lowerBound"`
	UpperBound *float64 `json:"upperBound"`
}

func (h *IntegralHandler) Integrate(c *gin.Context) {
	var req integrateReq
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, domain.ErrorResponseObj(http.StatusBadRequest, "invalid request: "+err.Error()))
		return
	}

	result, err := h.uc.Integrate(c.Request.Context(), req.Function, req.Variable, req.LowerBound, req.UpperBound)
	if err != nil {
		c.JSON(http.StatusUnprocessableEntity, domain.ErrorResponseObj(http.StatusUnprocessableEntity, err.Error()))
		return
	}

	c.JSON(http.StatusOK, domain.SuccessResponse("integration successful", result))
}
