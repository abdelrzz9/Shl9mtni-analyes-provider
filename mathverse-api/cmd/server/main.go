package main

import (
	"context"
	"fmt"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/abdelrzz9/math_app/mathverse-api/internal/config"
	"github.com/abdelrzz9/math_app/mathverse-api/internal/database"
	"github.com/abdelrzz9/math_app/mathverse-api/internal/router"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/rs/zerolog"
)

func main() {
	cfg := config.Load()

	logger := initLogger(cfg.LogLevel)
	logger.Info().Str("environment", cfg.AppEnvironment).Msg("starting mathverse-api")

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var pool *pgxpool.Pool
	if cfg.DBUrl != "" {
		var err error
		pool, err = database.NewPool(ctx, cfg.DBUrl)
		if err != nil {
			logger.Warn().Err(err).Msg("database connection failed, running without database")
			pool = nil
		} else {
			logger.Info().Msg("connected to database")
			defer pool.Close()
		}
	}

	deps := &router.Dependencies{
		Config: cfg,
		DBPool: pool,
		Logger: logger,
	}

	r := router.SetupRouter(deps)

	srv := &http.Server{
		Addr:         fmt.Sprintf(":%s", cfg.Port),
		Handler:      r,
		ReadTimeout:  10 * time.Second,
		WriteTimeout: 30 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	go func() {
		logger.Info().Str("port", cfg.Port).Msg("server listening")
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			logger.Fatal().Err(err).Msg("failed to start server")
		}
	}()

	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	sig := <-quit
	logger.Info().Str("signal", sig.String()).Msg("shutting down server")

	shutdownCtx, shutdownCancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer shutdownCancel()

	if err := srv.Shutdown(shutdownCtx); err != nil {
		logger.Error().Err(err).Msg("server forced to shutdown")
	}

	logger.Info().Msg("server exited gracefully")
}

func initLogger(level string) zerolog.Logger {
	l := zerolog.InfoLevel
	switch level {
	case "debug":
		l = zerolog.DebugLevel
	case "warn":
		l = zerolog.WarnLevel
	case "error":
		l = zerolog.ErrorLevel
	}

	output := zerolog.ConsoleWriter{
		Out:        os.Stdout,
		TimeFormat: time.RFC3339,
	}

	return zerolog.New(output).
		Level(l).
		With().
		Timestamp().
		Caller().
		Str("service", "mathverse-api").
		Logger()
}
