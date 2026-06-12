package handler

import (
	"net/http"

	"github.com/abdelrzz9/math_app/mathverse-api/internal/domain"
	"github.com/abdelrzz9/math_app/mathverse-api/internal/module/graph/usecase"
	"github.com/gin-gonic/gin"
)

type GraphHandler struct {
	uc *usecase.GraphUsecase
}

func NewGraphHandler(uc *usecase.GraphUsecase) *GraphHandler {
	return &GraphHandler{uc: uc}
}

type plotReq struct {
	Function string  `json:"function" binding:"required"`
	XMin     float64 `json:"xMin"`
	XMax     float64 `json:"xMax"`
	Step     float64 `json:"step"`
}

func (h *GraphHandler) Plot(c *gin.Context) {
	var req plotReq
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, domain.ErrorResponseObj(http.StatusBadRequest, "invalid request: "+err.Error()))
		return
	}

	result, err := h.uc.Plot(c.Request.Context(), req.Function, req.XMin, req.XMax, req.Step)
	if err != nil {
		c.JSON(http.StatusUnprocessableEntity, domain.ErrorResponseObj(http.StatusUnprocessableEntity, err.Error()))
		return
	}

	c.JSON(http.StatusOK, domain.SuccessResponse("plot data generated", result))
}
