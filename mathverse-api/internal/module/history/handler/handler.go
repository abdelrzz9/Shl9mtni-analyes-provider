package handler

import (
	"net/http"
	"strconv"

	"github.com/abdelrzz9/math_app/mathverse-api/internal/domain"
	"github.com/abdelrzz9/math_app/mathverse-api/internal/module/history/usecase"
	"github.com/gin-gonic/gin"
)

type HistoryHandler struct {
	uc *usecase.HistoryUsecase
}

func NewHistoryHandler(uc *usecase.HistoryUsecase) *HistoryHandler {
	return &HistoryHandler{uc: uc}
}

func (h *HistoryHandler) List(c *gin.Context) {
	userID, _ := c.Get("userID")
	uid, _ := userID.(string)

	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("pageSize", "20"))

	result, err := h.uc.List(c.Request.Context(), uid, page, pageSize)
	if err != nil {
		c.JSON(http.StatusInternalServerError, domain.ErrorResponseObj(http.StatusInternalServerError, err.Error()))
		return
	}

	c.JSON(http.StatusOK, domain.SuccessResponse("history retrieved", result))
}

func (h *HistoryHandler) Add(c *gin.Context) {
	userID, _ := c.Get("userID")
	uid, _ := userID.(string)

	var req usecase.AddEntryRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, domain.ErrorResponseObj(http.StatusBadRequest, "invalid request: "+err.Error()))
		return
	}

	entry, err := h.uc.Add(c.Request.Context(), uid, req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, domain.ErrorResponseObj(http.StatusInternalServerError, err.Error()))
		return
	}

	c.JSON(http.StatusCreated, domain.SuccessResponse("history entry added", entry))
}

func (h *HistoryHandler) Delete(c *gin.Context) {
	id := c.Param("id")

	if err := h.uc.Delete(c.Request.Context(), id); err != nil {
		c.JSON(http.StatusNotFound, domain.ErrorResponseObj(http.StatusNotFound, err.Error()))
		return
	}

	c.JSON(http.StatusOK, domain.SuccessResponse("history entry deleted", nil))
}

func (h *HistoryHandler) Clear(c *gin.Context) {
	userID, _ := c.Get("userID")
	uid, _ := userID.(string)

	if err := h.uc.Clear(c.Request.Context(), uid); err != nil {
		c.JSON(http.StatusInternalServerError, domain.ErrorResponseObj(http.StatusInternalServerError, err.Error()))
		return
	}

	c.JSON(http.StatusOK, domain.SuccessResponse("history cleared", nil))
}

func (h *HistoryHandler) ToggleFavorite(c *gin.Context) {
	id := c.Param("id")

	entry, err := h.uc.ToggleFavorite(c.Request.Context(), id)
	if err != nil {
		c.JSON(http.StatusNotFound, domain.ErrorResponseObj(http.StatusNotFound, err.Error()))
		return
	}

	c.JSON(http.StatusOK, domain.SuccessResponse("favorite toggled", entry))
}
