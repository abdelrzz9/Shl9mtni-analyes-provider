package config

import (
	"os"
	"strconv"
	"time"
)

type AppConfig struct {
	Port          string
	DBUrl         string
	RedisURL      string
	JWTSecret     string
	MathEngineURL string

	AuthTokenExpiry  time.Duration
	RefreshTokenExpiry time.Duration
	MaxLoginAttempts int
	LockoutDuration  time.Duration

	RateLimitRequestsPerMin int

	CORSAllowedOrigins []string

	LogLevel string

	EngineTimeout time.Duration

	AppEnvironment string
}

func Load() *AppConfig {
	return &AppConfig{
		Port:          getEnv("PORT", "8080"),
		DBUrl:         getEnv("DB_URL", "postgres://mathverse:mathverse@localhost:5432/mathverse?sslmode=disable"),
		RedisURL:      getEnv("REDIS_URL", ""),
		JWTSecret:     getEnv("JWT_SECRET", ""),
		MathEngineURL: getEnv("MATH_ENGINE_URL", "http://localhost:8000"),

		AuthTokenExpiry:    getDurationEnv("AUTH_TOKEN_EXPIRY", 15*time.Minute),
		RefreshTokenExpiry: getDurationEnv("REFRESH_TOKEN_EXPIRY", 7*24*time.Hour),
		MaxLoginAttempts:   getIntEnv("MAX_LOGIN_ATTEMPTS", 5),
		LockoutDuration:    getDurationEnv("LOCKOUT_DURATION", 15*time.Minute),

		RateLimitRequestsPerMin: getIntEnv("RATE_LIMIT_REQUESTS_PER_MIN", 60),

		CORSAllowedOrigins: getStringSliceEnv("CORS_ALLOWED_ORIGINS", []string{"http://localhost:3000"}),

		LogLevel: getEnv("LOG_LEVEL", "info"),

		EngineTimeout: getDurationEnv("ENGINE_TIMEOUT", 30*time.Second),

		AppEnvironment: getEnv("APP_ENV", "development"),
	}
}

func getEnv(key, fallback string) string {
	if val := os.Getenv(key); val != "" {
		return val
	}
	return fallback
}

func getIntEnv(key string, fallback int) int {
	if val := os.Getenv(key); val != "" {
		if i, err := strconv.Atoi(val); err == nil {
			return i
		}
	}
	return fallback
}

func getDurationEnv(key string, fallback time.Duration) time.Duration {
	if val := os.Getenv(key); val != "" {
		if d, err := time.ParseDuration(val); err == nil {
			return d
		}
	}
	return fallback
}

func getStringSliceEnv(key string, fallback []string) []string {
	if val := os.Getenv(key); val != "" {
		origins := []string{}
		for _, s := range splitAndTrim(val, ",") {
			if s != "" {
				origins = append(origins, s)
			}
		}
		if len(origins) > 0 {
			return origins
		}
	}
	return fallback
}

func splitAndTrim(s, sep string) []string {
	var result []string
	start := 0
	for i := 0; i < len(s); i++ {
		if s[i] == sep[0] {
			result = append(result, trimSpace(s[start:i]))
			start = i + 1
		}
	}
	result = append(result, trimSpace(s[start:]))
	return result
}

func trimSpace(s string) string {
	start, end := 0, len(s)
	for start < end && (s[start] == ' ' || s[start] == '\t' || s[start] == '\n' || s[start] == '\r') {
		start++
	}
	for end > start && (s[end-1] == ' ' || s[end-1] == '\t' || s[end-1] == '\n' || s[end-1] == '\r') {
		end--
	}
	return s[start:end]
}
