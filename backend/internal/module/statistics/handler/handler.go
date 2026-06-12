package handler

import (
	"net/http"

	"github.com/abdelrzz9/math_app/backend/internal/domain"
	"github.com/abdelrzz9/math_app/backend/internal/module/statistics/usecase"
	"github.com/gin-gonic/gin"
)

type StatisticHandler struct {
	uc *usecase.StatisticUsecase
}

func NewStatisticHandler(uc *usecase.StatisticUsecase) *StatisticHandler {
	return &StatisticHandler{uc: uc}
}

type calculateReq struct {
	Data      []float64 `json:"data" binding:"required"`
	Operation string    `json:"operation" binding:"required"`
}

func (h *StatisticHandler) Calculate(c *gin.Context) {
	var req calculateReq
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, domain.ErrorResponseObj(http.StatusBadRequest, "invalid request: "+err.Error()))
		return
	}

	result, err := h.uc.Calculate(req.Data, req.Operation)
	if err != nil {
		c.JSON(http.StatusUnprocessableEntity, domain.ErrorResponseObj(http.StatusUnprocessableEntity, err.Error()))
		return
	}

	c.JSON(http.StatusOK, domain.SuccessResponse("statistical calculation successful", result))
}
