package middleware

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/rs/zerolog"
)

func RecoveryMiddleware(logger zerolog.Logger) gin.HandlerFunc {
	return func(c *gin.Context) {
		defer func() {
			if err := recover(); err != nil {
				logger.Error().
					Str("path", c.Request.URL.Path).
					Str("method", c.Request.Method).
					Interface("panic", err).
					Msg("panic recovered")

				c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{
					"code":    500,
					"message": "internal server error",
				})
			}
		}()
		c.Next()
	}
}
