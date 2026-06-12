package middleware

import (
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/rs/zerolog"
)

func LoggingMiddleware(logger zerolog.Logger) gin.HandlerFunc {
	return func(c *gin.Context) {
		start := time.Now()
		correlationID := c.GetHeader("X-Correlation-ID")
		if correlationID == "" {
			correlationID = uuid.New().String()
		}

		c.Set("correlationID", correlationID)
		c.Header("X-Correlation-ID", correlationID)

		path := c.Request.URL.Path
		raw := c.Request.URL.RawQuery

		c.Next()

		latency := time.Since(start)
		statusCode := c.Writer.Status()

		logEvent := logger.Info()
		if statusCode >= 400 {
			logEvent = logger.Error()
		}

		logEvent.
			Str("correlation_id", correlationID).
			Str("method", c.Request.Method).
			Str("path", path).
			Int("status", statusCode).
			Dur("latency", latency).
			Str("client_ip", c.ClientIP()).
			Int("body_size", c.Writer.Size()).
			Msg("request completed")

		if raw != "" {
			c.Request.URL.RawQuery = raw
		}
	}
}

func GetCorrelationID(c *gin.Context) string {
	if id, exists := c.Get("correlationID"); exists {
		return id.(string)
	}
	return ""
}
