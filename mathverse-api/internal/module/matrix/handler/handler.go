package handler

import (
	"net/http"

	"github.com/abdelrzz9/math_app/mathverse-api/internal/domain"
	"github.com/abdelrzz9/math_app/mathverse-api/internal/module/matrix/usecase"
	"github.com/gin-gonic/gin"
)

type MatrixHandler struct {
	uc *usecase.MatrixUsecase
}

func NewMatrixHandler(uc *usecase.MatrixUsecase) *MatrixHandler {
	return &MatrixHandler{uc: uc}
}

type matrixBinaryReq struct {
	MatrixA usecase.Matrix `json:"matrixA" binding:"required"`
	MatrixB usecase.Matrix `json:"matrixB" binding:"required"`
}

type matrixUnaryReq struct {
	Matrix usecase.Matrix `json:"matrix" binding:"required"`
}

func (h *MatrixHandler) Add(c *gin.Context) {
	var req matrixBinaryReq
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, domain.ErrorResponseObj(http.StatusBadRequest, "invalid request: "+err.Error()))
		return
	}

	result, err := h.uc.Add(c.Request.Context(), req.MatrixA, req.MatrixB)
	if err != nil {
		c.JSON(http.StatusUnprocessableEntity, domain.ErrorResponseObj(http.StatusUnprocessableEntity, err.Error()))
		return
	}

	c.JSON(http.StatusOK, domain.SuccessResponse("matrix addition successful", result))
}

func (h *MatrixHandler) Multiply(c *gin.Context) {
	var req matrixBinaryReq
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, domain.ErrorResponseObj(http.StatusBadRequest, "invalid request: "+err.Error()))
		return
	}

	result, err := h.uc.Multiply(c.Request.Context(), req.MatrixA, req.MatrixB)
	if err != nil {
		c.JSON(http.StatusUnprocessableEntity, domain.ErrorResponseObj(http.StatusUnprocessableEntity, err.Error()))
		return
	}

	c.JSON(http.StatusOK, domain.SuccessResponse("matrix multiplication successful", result))
}

func (h *MatrixHandler) Determinant(c *gin.Context) {
	var req matrixUnaryReq
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, domain.ErrorResponseObj(http.StatusBadRequest, "invalid request: "+err.Error()))
		return
	}

	result, err := h.uc.Determinant(c.Request.Context(), req.Matrix)
	if err != nil {
		c.JSON(http.StatusUnprocessableEntity, domain.ErrorResponseObj(http.StatusUnprocessableEntity, err.Error()))
		return
	}

	c.JSON(http.StatusOK, domain.SuccessResponse("determinant calculation successful", result))
}

func (h *MatrixHandler) Inverse(c *gin.Context) {
	var req matrixUnaryReq
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, domain.ErrorResponseObj(http.StatusBadRequest, "invalid request: "+err.Error()))
		return
	}

	result, err := h.uc.Inverse(c.Request.Context(), req.Matrix)
	if err != nil {
		c.JSON(http.StatusUnprocessableEntity, domain.ErrorResponseObj(http.StatusUnprocessableEntity, err.Error()))
		return
	}

	c.JSON(http.StatusOK, domain.SuccessResponse("matrix inverse successful", result))
}

func (h *MatrixHandler) Transpose(c *gin.Context) {
	var req matrixUnaryReq
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, domain.ErrorResponseObj(http.StatusBadRequest, "invalid request: "+err.Error()))
		return
	}

	result, err := h.uc.Transpose(c.Request.Context(), req.Matrix)
	if err != nil {
		c.JSON(http.StatusUnprocessableEntity, domain.ErrorResponseObj(http.StatusUnprocessableEntity, err.Error()))
		return
	}

	c.JSON(http.StatusOK, domain.SuccessResponse("matrix transpose successful", result))
}
