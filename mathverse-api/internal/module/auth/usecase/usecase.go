package usecase

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"errors"
	"time"

	"github.com/abdelrzz9/math_app/mathverse-api/internal/config"
	"github.com/abdelrzz9/math_app/mathverse-api/internal/module/auth/repository"
	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
)

var (
	ErrInvalidCredentials = errors.New("invalid email or password")
	ErrAccountLocked      = errors.New("account is locked due to too many failed attempts")
	ErrEmailTaken         = errors.New("email already registered")
	ErrInvalidToken       = errors.New("invalid or expired token")
	ErrTokenRevoked       = errors.New("token has been revoked")
)

type AuthUsecase struct {
	repo repository.AuthRepository
	cfg  *config.AppConfig
}

func NewAuthUsecase(repo repository.AuthRepository, cfg *config.AppConfig) *AuthUsecase {
	return &AuthUsecase{repo: repo, cfg: cfg}
}

type RegisterRequest struct {
	Email       string `json:"email" binding:"required,email"`
	Password    string `json:"password" binding:"required,min=8"`
	DisplayName string `json:"displayName" binding:"required,min=1,max=100"`
}

type LoginRequest struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required"`
}

type TokenResponse struct {
	AccessToken  string `json:"accessToken"`
	RefreshToken string `json:"refreshToken"`
	ExpiresIn    int    `json:"expiresIn"`
	UserID       string `json:"userId"`
	DisplayName  string `json:"displayName"`
}

type UserProfile struct {
	ID          string     `json:"id"`
	Email       string     `json:"email"`
	DisplayName string     `json:"displayName"`
	CreatedAt   time.Time  `json:"createdAt"`
	LastLoginAt *time.Time `json:"lastLoginAt,omitempty"`
}

func (uc *AuthUsecase) Register(ctx context.Context, req RegisterRequest) (*TokenResponse, error) {
	existing, _ := uc.repo.GetUserByEmail(ctx, req.Email)
	if existing != nil {
		return nil, ErrEmailTaken
	}

	passwordHash, err := repository.HashPassword(req.Password)
	if err != nil {
		return nil, err
	}

	user := &repository.User{
		ID:           uuid.New().String(),
		Email:        req.Email,
		PasswordHash: passwordHash,
		DisplayName:  req.DisplayName,
		CreatedAt:    time.Now().UTC(),
		UpdatedAt:    time.Now().UTC(),
	}

	if err := uc.repo.CreateUser(ctx, user); err != nil {
		return nil, err
	}

	return uc.generateTokens(ctx, user)
}

func (uc *AuthUsecase) Login(ctx context.Context, req LoginRequest) (*TokenResponse, error) {
	user, err := uc.repo.GetUserByEmail(ctx, req.Email)
	if err != nil {
		if errors.Is(err, repository.ErrUserNotFound) {
			return nil, ErrInvalidCredentials
		}
		return nil, err
	}

	if user.LockedUntil != nil && time.Now().Before(*user.LockedUntil) {
		return nil, ErrAccountLocked
	}

	if !repository.CheckPassword(req.Password, user.PasswordHash) {
		attempts := user.LoginAttempts + 1
		var lockedUntil *time.Time
		if attempts >= uc.cfg.MaxLoginAttempts {
			t := time.Now().Add(uc.cfg.LockoutDuration)
			lockedUntil = &t
		}
		_ = uc.repo.UpdateLoginAttempts(ctx, user.ID, attempts, lockedUntil)
		return nil, ErrInvalidCredentials
	}

	_ = uc.repo.UpdateLastLogin(ctx, user.ID)

	return uc.generateTokens(ctx, user)
}

func (uc *AuthUsecase) RefreshToken(ctx context.Context, refreshTokenStr string) (*TokenResponse, error) {
	refreshTokenID, userID, err := uc.decodeRefreshToken(refreshTokenStr)
	if err != nil {
		return nil, ErrInvalidToken
	}

	storedToken, err := uc.repo.GetRefreshToken(ctx, refreshTokenID)
	if err != nil {
		return nil, err
	}
	if storedToken == nil {
		return nil, ErrInvalidToken
	}
	if storedToken.Revoked {
		_ = uc.repo.RevokeAllUserRefreshTokens(ctx, storedToken.UserID)
		return nil, ErrTokenRevoked
	}
	if time.Now().After(storedToken.ExpiresAt) {
		return nil, ErrInvalidToken
	}

	if err := bcrypt.CompareHashAndPassword([]byte(storedToken.TokenHash), []byte(refreshTokenStr)); err != nil {
		return nil, ErrInvalidToken
	}

	if err := uc.repo.RevokeRefreshToken(ctx, refreshTokenID); err != nil {
		return nil, err
	}

	user, err := uc.repo.GetUserByID(ctx, userID)
	if err != nil {
		return nil, err
	}

	return uc.generateTokens(ctx, user)
}

func (uc *AuthUsecase) Logout(ctx context.Context, userID string) error {
	return uc.repo.RevokeAllUserRefreshTokens(ctx, userID)
}

func (uc *AuthUsecase) GetProfile(ctx context.Context, userID string) (*UserProfile, error) {
	user, err := uc.repo.GetUserByID(ctx, userID)
	if err != nil {
		return nil, err
	}
	return &UserProfile{
		ID:          user.ID,
		Email:       user.Email,
		DisplayName: user.DisplayName,
		CreatedAt:   user.CreatedAt,
		LastLoginAt: user.LastLoginAt,
	}, nil
}

func (uc *AuthUsecase) generateTokens(ctx context.Context, user *repository.User) (*TokenResponse, error) {
	accessTokenID := uuid.New().String()
	accessToken := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"user_id":    user.ID,
		"token_id":   accessTokenID,
		"email":      user.Email,
		"exp":        time.Now().Add(uc.cfg.AuthTokenExpiry).Unix(),
		"iat":        time.Now().Unix(),
		"token_type": "access",
	})

	accessTokenStr, err := accessToken.SignedString([]byte(uc.cfg.JWTSecret))
	if err != nil {
		return nil, err
	}

	refreshTokenID := uuid.New().String()
	refreshTokenRaw := uuid.New().String()

	refreshTokenHash, err := bcrypt.GenerateFromPassword([]byte(refreshTokenRaw), bcrypt.DefaultCost)
	if err != nil {
		return nil, err
	}

	refreshTokenRecord := &repository.RefreshToken{
		ID:        refreshTokenID,
		UserID:    user.ID,
		TokenHash: string(refreshTokenHash),
		ExpiresAt: time.Now().Add(uc.cfg.RefreshTokenExpiry),
		CreatedAt: time.Now().UTC(),
	}

	if err := uc.repo.SaveRefreshToken(ctx, refreshTokenRecord); err != nil {
		return nil, err
	}

	refreshTokenJWT := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"user_id":         user.ID,
		"refresh_token_id": refreshTokenID,
		"token_hash":      refreshTokenRaw,
		"exp":             time.Now().Add(uc.cfg.RefreshTokenExpiry).Unix(),
		"iat":             time.Now().Unix(),
		"token_type":      "refresh",
	})

	refreshTokenStr, err := refreshTokenJWT.SignedString([]byte(uc.cfg.JWTSecret))
	if err != nil {
		return nil, err
	}

	return &TokenResponse{
		AccessToken:  accessTokenStr,
		RefreshToken: refreshTokenStr,
		ExpiresIn:    int(uc.cfg.AuthTokenExpiry.Seconds()),
		UserID:       user.ID,
		DisplayName:  user.DisplayName,
	}, nil
}

func (uc *AuthUsecase) decodeRefreshToken(tokenStr string) (tokenID, userID string, err error) {
	token, err := jwt.Parse(tokenStr, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, jwt.ErrSignatureInvalid
		}
		return []byte(uc.cfg.JWTSecret), nil
	})
	if err != nil || !token.Valid {
		return "", "", ErrInvalidToken
	}

	claims, ok := token.Claims.(jwt.MapClaims)
	if !ok {
		return "", "", ErrInvalidToken
	}

	tokenType, _ := claims["token_type"].(string)
	if tokenType != "refresh" {
		return "", "", ErrInvalidToken
	}

	tokenID, _ = claims["refresh_token_id"].(string)
	userID, _ = claims["user_id"].(string)

	if tokenID == "" || userID == "" {
		return "", "", ErrInvalidToken
	}

	return tokenID, userID, nil
}

func generateRandomString(length int) (string, error) {
	bytes := make([]byte, length)
	if _, err := rand.Read(bytes); err != nil {
		return "", err
	}
	return hex.EncodeToString(bytes), nil
}
