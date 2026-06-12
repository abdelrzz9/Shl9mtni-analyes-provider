package handler

import (
	"net/http"

	"github.com/abdelrzz9/math_app/backend/internal/domain"
	"github.com/abdelrzz9/math_app/backend/internal/module/derivatives/usecase"
	"github.com/gin-gonic/gin"
)

type DerivativeHandler struct {
	uc *usecase.DerivativeUsecase
}

func NewDerivativeHandler(uc *usecase.DerivativeUsecase) *DerivativeHandler {
	return &DerivativeHandler{uc: uc}
}

type differentiateReq struct {
	Function string `json:"function" binding:"required"`
	Variable string `json:"variable" binding:"required"`
	Order    int    `json:"order"`
}

func (h *DerivativeHandler) Differentiate(c *gin.Context) {
	var req differentiateReq
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, domain.ErrorResponseObj(http.StatusBadRequest, "invalid request: "+err.Error()))
		return
	}
	if req.Order <= 0 {
		req.Order = 1
	}

	result, err := h.uc.Differentiate(c.Request.Context(), req.Function, req.Variable, req.Order)
	if err != nil {
		c.JSON(http.StatusUnprocessableEntity, domain.ErrorResponseObj(http.StatusUnprocessableEntity, err.Error()))
		return
	}

	c.JSON(http.StatusOK, domain.SuccessResponse("differentiation successful", result))
}
