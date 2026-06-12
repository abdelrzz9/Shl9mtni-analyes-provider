package handler

import (
	"net/http"

	"github.com/abdelrzz9/math_app/backend/internal/domain"
	"github.com/abdelrzz9/math_app/backend/internal/module/taylor/usecase"
	"github.com/gin-gonic/gin"
)

type TaylorHandler struct {
	uc *usecase.TaylorUsecase
}

func NewTaylorHandler(uc *usecase.TaylorUsecase) *TaylorHandler {
	return &TaylorHandler{uc: uc}
}

type taylorExpandReq struct {
	Function string  `json:"function" binding:"required"`
	Variable string  `json:"variable" binding:"required"`
	Center   float64 `json:"center"`
	Order    int     `json:"order"`
}

func (h *TaylorHandler) Expand(c *gin.Context) {
	var req taylorExpandReq
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, domain.ErrorResponseObj(http.StatusBadRequest, "invalid request: "+err.Error()))
		return
	}
	if req.Order <= 0 {
		req.Order = 3
	}

	result, err := h.uc.Expand(c.Request.Context(), req.Function, req.Variable, req.Center, req.Order)
	if err != nil {
		c.JSON(http.StatusUnprocessableEntity, domain.ErrorResponseObj(http.StatusUnprocessableEntity, err.Error()))
		return
	}

	c.JSON(http.StatusOK, domain.SuccessResponse("taylor expansion successful", result))
}
