package usecase

import (
	"context"
	"errors"
	"testing"
	"time"

	"github.com/abdelrzz9/math_app/mathverse-api/internal/config"
	"github.com/abdelrzz9/math_app/mathverse-api/internal/module/auth/repository"
)

type mockAuthRepo struct {
	users           map[string]*repository.User
	refreshTokens   map[string]*repository.RefreshToken
	createUserErr   error
	getUserByIDErr  error
	saveTokenErr    error
	getTokenErr     error
	revokeTokenErr  error
	revokeAllErr    error
	updateAttempts  error
	updateLastLogin error
}

func newMockAuthRepo() *mockAuthRepo {
	return &mockAuthRepo{
		users:         make(map[string]*repository.User),
		refreshTokens: make(map[string]*repository.RefreshToken),
	}
}

func (m *mockAuthRepo) CreateUser(ctx context.Context, user *repository.User) error {
	if m.createUserErr != nil {
		return m.createUserErr
	}
	if _, exists := m.users[user.Email]; exists {
		return repository.ErrEmailAlreadyExists
	}
	m.users[user.Email] = user
	m.users[user.ID] = user
	return nil
}

func (m *mockAuthRepo) GetUserByEmail(ctx context.Context, email string) (*repository.User, error) {
	if u, ok := m.users[email]; ok {
		return u, nil
	}
	return nil, repository.ErrUserNotFound
}

func (m *mockAuthRepo) GetUserByID(ctx context.Context, id string) (*repository.User, error) {
	if m.getUserByIDErr != nil {
		return nil, m.getUserByIDErr
	}
	for _, u := range m.users {
		if u.ID == id {
			return u, nil
		}
	}
	return nil, repository.ErrUserNotFound
}

func (m *mockAuthRepo) UpdateLoginAttempts(ctx context.Context, userID string, attempts int, lockedUntil *time.Time) error {
	return m.updateAttempts
}

func (m *mockAuthRepo) UpdateLastLogin(ctx context.Context, userID string) error {
	return m.updateLastLogin
}

func (m *mockAuthRepo) SaveRefreshToken(ctx context.Context, token *repository.RefreshToken) error {
	if m.saveTokenErr != nil {
		return m.saveTokenErr
	}
	m.refreshTokens[token.ID] = token
	return nil
}

func (m *mockAuthRepo) GetRefreshToken(ctx context.Context, tokenID string) (*repository.RefreshToken, error) {
	if m.getTokenErr != nil {
		return nil, m.getTokenErr
	}
	t, ok := m.refreshTokens[tokenID]
	if !ok {
		return nil, nil
	}
	return t, nil
}

func (m *mockAuthRepo) RevokeRefreshToken(ctx context.Context, tokenID string) error {
	if m.revokeTokenErr != nil {
		return m.revokeTokenErr
	}
	if t, ok := m.refreshTokens[tokenID]; ok {
		t.Revoked = true
	}
	return nil
}

func (m *mockAuthRepo) RevokeAllUserRefreshTokens(ctx context.Context, userID string) error {
	if m.revokeAllErr != nil {
		return m.revokeAllErr
	}
	for _, t := range m.refreshTokens {
		if t.UserID == userID {
			t.Revoked = true
		}
	}
	return nil
}

func testConfig() *config.AppConfig {
	return &config.AppConfig{
		JWTSecret:           "test-secret-key-that-is-long-enough-for-hs256",
		AuthTokenExpiry:     15 * time.Minute,
		RefreshTokenExpiry:  24 * time.Hour,
		MaxLoginAttempts:    5,
		LockoutDuration:     15 * time.Minute,
		RateLimitRequestsPerMin: 60,
		CORSAllowedOrigins:  []string{"*"},
		LogLevel:            "debug",
		EngineTimeout:       30 * time.Second,
		AppEnvironment:      "test",
	}
}

func TestRegister_Success(t *testing.T) {
	repo := newMockAuthRepo()
	cfg := testConfig()
	uc := NewAuthUsecase(repo, cfg)

	result, err := uc.Register(context.Background(), RegisterRequest{
		Email:       "test@example.com",
		Password:    "password123",
		DisplayName: "Test User",
	})
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if result.UserID == "" {
		t.Error("expected non-empty userID")
	}
	if result.DisplayName != "Test User" {
		t.Errorf("expected 'Test User', got '%s'", result.DisplayName)
	}
	if result.AccessToken == "" {
		t.Error("expected non-empty access token")
	}
	if result.RefreshToken == "" {
		t.Error("expected non-empty refresh token")
	}
	if result.ExpiresIn <= 0 {
		t.Error("expected positive expiresIn")
	}
}

func TestRegister_DuplicateEmail(t *testing.T) {
	repo := newMockAuthRepo()
	cfg := testConfig()
	uc := NewAuthUsecase(repo, cfg)

	_, err := uc.Register(context.Background(), RegisterRequest{
		Email:       "test@example.com",
		Password:    "password123",
		DisplayName: "User One",
	})
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	_, err = uc.Register(context.Background(), RegisterRequest{
		Email:       "test@example.com",
		Password:    "password456",
		DisplayName: "User Two",
	})
	if !errors.Is(err, ErrEmailTaken) {
		t.Errorf("expected ErrEmailTaken, got %v", err)
	}
}

func TestLogin_Success(t *testing.T) {
	repo := newMockAuthRepo()
	cfg := testConfig()
	uc := NewAuthUsecase(repo, cfg)

	regResult, err := uc.Register(context.Background(), RegisterRequest{
		Email:       "test@example.com",
		Password:    "password123",
		DisplayName: "Test User",
	})
	if err != nil {
		t.Fatalf("registration failed: %v", err)
	}

	result, err := uc.Login(context.Background(), LoginRequest{
		Email:    "test@example.com",
		Password: "password123",
	})
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if result.UserID != regResult.UserID {
		t.Errorf("expected userID %s, got %s", regResult.UserID, result.UserID)
	}
}

func TestLogin_InvalidPassword(t *testing.T) {
	repo := newMockAuthRepo()
	cfg := testConfig()
	uc := NewAuthUsecase(repo, cfg)

	_, err := uc.Register(context.Background(), RegisterRequest{
		Email:       "test@example.com",
		Password:    "password123",
		DisplayName: "Test User",
	})
	if err != nil {
		t.Fatalf("registration failed: %v", err)
	}

	_, err = uc.Login(context.Background(), LoginRequest{
		Email:    "test@example.com",
		Password: "wrongpassword",
	})
	if !errors.Is(err, ErrInvalidCredentials) {
		t.Errorf("expected ErrInvalidCredentials, got %v", err)
	}
}

func TestLogin_NonExistentEmail(t *testing.T) {
	repo := newMockAuthRepo()
	cfg := testConfig()
	uc := NewAuthUsecase(repo, cfg)

	_, err := uc.Login(context.Background(), LoginRequest{
		Email:    "nonexistent@example.com",
		Password: "password123",
	})
	if !errors.Is(err, ErrInvalidCredentials) {
		t.Errorf("expected ErrInvalidCredentials, got %v", err)
	}
}

func TestLogin_AccountLocked(t *testing.T) {
	repo := newMockAuthRepo()
	cfg := testConfig()
	cfg.MaxLoginAttempts = 3
	uc := NewAuthUsecase(repo, cfg)

	_, err := uc.Register(context.Background(), RegisterRequest{
		Email:       "test@example.com",
		Password:    "password123",
		DisplayName: "Test User",
	})
	if err != nil {
		t.Fatalf("registration failed: %v", err)
	}

	for i := 0; i < cfg.MaxLoginAttempts; i++ {
		_, err = uc.Login(context.Background(), LoginRequest{
			Email:    "test@example.com",
			Password: "wrongpassword",
		})
		if err == nil {
			t.Fatalf("expected error on attempt %d", i+1)
		}
	}

	user, _ := repo.GetUserByEmail(context.Background(), "test@example.com")
	lockedUntil := time.Now().Add(time.Hour)
	user.LockedUntil = &lockedUntil
	user.LoginAttempts = 3

	_, err = uc.Login(context.Background(), LoginRequest{
		Email:    "test@example.com",
		Password: "password123",
	})
	if !errors.Is(err, ErrAccountLocked) {
		t.Errorf("expected ErrAccountLocked, got %v", err)
	}
}

func TestRefreshToken_InvalidToken(t *testing.T) {
	repo := newMockAuthRepo()
	cfg := testConfig()
	uc := NewAuthUsecase(repo, cfg)

	_, err := uc.RefreshToken(context.Background(), "invalid-token-string")
	if !errors.Is(err, ErrInvalidToken) {
		t.Errorf("expected ErrInvalidToken, got %v", err)
	}
}

func TestLogout_Success(t *testing.T) {
	repo := newMockAuthRepo()
	cfg := testConfig()
	uc := NewAuthUsecase(repo, cfg)

	regResult, err := uc.Register(context.Background(), RegisterRequest{
		Email:       "test@example.com",
		Password:    "password123",
		DisplayName: "Test User",
	})
	if err != nil {
		t.Fatalf("registration failed: %v", err)
	}

	err = uc.Logout(context.Background(), regResult.UserID)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
}

func TestGetProfile_Success(t *testing.T) {
	repo := newMockAuthRepo()
	cfg := testConfig()
	uc := NewAuthUsecase(repo, cfg)

	regResult, err := uc.Register(context.Background(), RegisterRequest{
		Email:       "test@example.com",
		Password:    "password123",
		DisplayName: "Test User",
	})
	if err != nil {
		t.Fatalf("registration failed: %v", err)
	}

	profile, err := uc.GetProfile(context.Background(), regResult.UserID)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if profile.Email != "test@example.com" {
		t.Errorf("expected 'test@example.com', got '%s'", profile.Email)
	}
	if profile.DisplayName != "Test User" {
		t.Errorf("expected 'Test User', got '%s'", profile.DisplayName)
	}
}

func TestGetProfile_NotFound(t *testing.T) {
	repo := newMockAuthRepo()
	cfg := testConfig()
	uc := NewAuthUsecase(repo, cfg)

	_, err := uc.GetProfile(context.Background(), "non-existent-id")
	if err == nil {
		t.Fatal("expected error, got nil")
	}
}

func TestLogin_ResetsAttemptsOnSuccess(t *testing.T) {
	repo := newMockAuthRepo()
	cfg := testConfig()
	uc := NewAuthUsecase(repo, cfg)

	_, err := uc.Register(context.Background(), RegisterRequest{
		Email:       "test@example.com",
		Password:    "password123",
		DisplayName: "Test User",
	})
	if err != nil {
		t.Fatalf("registration failed: %v", err)
	}

	for i := 0; i < 3; i++ {
		uc.Login(context.Background(), LoginRequest{
			Email:    "test@example.com",
			Password: "wrongpassword",
		})
	}

	result, err := uc.Login(context.Background(), LoginRequest{
		Email:    "test@example.com",
		Password: "password123",
	})
	if err != nil {
		t.Fatalf("expected successful login after failed attempts: %v", err)
	}
	if result.AccessToken == "" {
		t.Error("expected access token after successful login")
	}
}
