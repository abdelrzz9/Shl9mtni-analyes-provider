package config

import "os"

type AppConfig struct {
	Port          string
	DBUrl         string
	RedisURL      string
	JWTSecret     string
	MathEngineURL string
}

func Load() *AppConfig {
	return &AppConfig{
		Port:          getEnv("PORT", "8080"),
		DBUrl:         getEnv("DB_URL", ""),
		RedisURL:      getEnv("REDIS_URL", ""),
		JWTSecret:     getEnv("JWT_SECRET", "default-secret-key"),
		MathEngineURL: getEnv("MATH_ENGINE_URL", "http://localhost:8000"),
	}
}

func getEnv(key, fallback string) string {
	if val := os.Getenv(key); val != "" {
		return val
	}
	return fallback
}
