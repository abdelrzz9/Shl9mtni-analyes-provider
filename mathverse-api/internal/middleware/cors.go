package middleware

import (
	"strings"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

func CORSMiddleware(allowedOrigins []string) gin.HandlerFunc {
	allowAll := false
	for _, o := range allowedOrigins {
		if o == "*" {
			allowAll = true
			break
		}
	}

	var origins []string
	if !allowAll {
		origins = allowedOrigins
	}

	return cors.New(cors.Config{
		AllowOrigins:     origins,
		AllowMethods:     []string{"GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Accept", "Authorization", "X-Correlation-ID"},
		ExposeHeaders:    []string{"Content-Length", "X-Correlation-ID"},
		AllowCredentials: !allowAll,
		AllowWildcard:    false,
		MaxAge:           12 * time.Hour,
		AllowOriginFunc: func(origin string) bool {
			if allowAll {
				return true
			}
			for _, o := range origins {
				if matchOrigin(origin, o) {
					return true
				}
			}
			return false
		},
	})
}

func matchOrigin(origin, allowed string) bool {
	if allowed == "*" {
		return true
	}
	if strings.HasPrefix(allowed, "https://*.") {
		suffix := allowed[9:]
		return strings.HasSuffix(origin, suffix) && strings.HasPrefix(origin, "https://")
	}
	return origin == allowed
}
