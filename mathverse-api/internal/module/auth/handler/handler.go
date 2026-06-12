package handler

import (
	"errors"
	"net/http"

	"github.com/abdelrzz9/math_app/mathverse-api/internal/domain"
	"github.com/abdelrzz9/math_app/mathverse-api/internal/module/auth/usecase"
	"github.com/gin-gonic/gin"
)

type AuthHandler struct {
	uc *usecase.AuthUsecase
}

func NewAuthHandler(uc *usecase.AuthUsecase) *AuthHandler {
	return &AuthHandler{uc: uc}
}

func (h *AuthHandler) Register(c *gin.Context) {
	var req usecase.RegisterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, domain.ErrorResponseObj(http.StatusBadRequest, "invalid request: "+err.Error()))
		return
	}

	result, err := h.uc.Register(c.Request.Context(), req)
	if err != nil {
		switch {
		case errors.Is(err, usecase.ErrEmailTaken):
			c.JSON(http.StatusConflict, domain.ErrorResponseObj(http.StatusConflict, err.Error()))
		default:
			c.JSON(http.StatusInternalServerError, domain.ErrorResponseObj(http.StatusInternalServerError, "registration failed"))
		}
		return
	}

	c.JSON(http.StatusCreated, domain.SuccessResponse("registration successful", result))
}

func (h *AuthHandler) Login(c *gin.Context) {
	var req usecase.LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, domain.ErrorResponseObj(http.StatusBadRequest, "invalid request: "+err.Error()))
		return
	}

	result, err := h.uc.Login(c.Request.Context(), req)
	if err != nil {
		switch {
		case errors.Is(err, usecase.ErrInvalidCredentials):
			c.JSON(http.StatusUnauthorized, domain.ErrorResponseObj(http.StatusUnauthorized, err.Error()))
		case errors.Is(err, usecase.ErrAccountLocked):
			c.JSON(http.StatusTooManyRequests, domain.ErrorResponseObj(http.StatusTooManyRequests, err.Error()))
		default:
			c.JSON(http.StatusInternalServerError, domain.ErrorResponseObj(http.StatusInternalServerError, "login failed"))
		}
		return
	}

	c.JSON(http.StatusOK, domain.SuccessResponse("login successful", result))
}

func (h *AuthHandler) RefreshToken(c *gin.Context) {
	var req struct {
		RefreshToken string `json:"refreshToken" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, domain.ErrorResponseObj(http.StatusBadRequest, "invalid request: "+err.Error()))
		return
	}

	result, err := h.uc.RefreshToken(c.Request.Context(), req.RefreshToken)
	if err != nil {
		switch {
		case errors.Is(err, usecase.ErrInvalidToken), errors.Is(err, usecase.ErrTokenRevoked):
			c.JSON(http.StatusUnauthorized, domain.ErrorResponseObj(http.StatusUnauthorized, err.Error()))
		default:
			c.JSON(http.StatusInternalServerError, domain.ErrorResponseObj(http.StatusInternalServerError, "token refresh failed"))
		}
		return
	}

	c.JSON(http.StatusOK, domain.SuccessResponse("token refreshed", result))
}

func (h *AuthHandler) Logout(c *gin.Context) {
	userID, _ := c.Get("userID")
	uid, _ := userID.(string)

	if err := h.uc.Logout(c.Request.Context(), uid); err != nil {
		c.JSON(http.StatusInternalServerError, domain.ErrorResponseObj(http.StatusInternalServerError, "logout failed"))
		return
	}

	c.JSON(http.StatusOK, domain.SuccessResponse("logout successful", nil))
}

func (h *AuthHandler) Profile(c *gin.Context) {
	userID, _ := c.Get("userID")
	uid, _ := userID.(string)

	profile, err := h.uc.GetProfile(c.Request.Context(), uid)
	if err != nil {
		c.JSON(http.StatusNotFound, domain.ErrorResponseObj(http.StatusNotFound, "user not found"))
		return
	}

	c.JSON(http.StatusOK, domain.SuccessResponse("profile retrieved", profile))
}
