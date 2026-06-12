package middleware

import (
	"net/http"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
)

type RateLimiter struct {
	mu       sync.Mutex
	requests map[string]*rateLimitEntry
	rate     int
	window   time.Duration
}

type rateLimitEntry struct {
	count    int
	windowStart time.Time
}

func NewRateLimiter(requestsPerMin int) *RateLimiter {
	rl := &RateLimiter{
		requests: make(map[string]*rateLimitEntry),
		rate:     requestsPerMin,
		window:   time.Minute,
	}

	go rl.cleanup()

	return rl
}

func (rl *RateLimiter) cleanup() {
	ticker := time.NewTicker(5 * time.Minute)
	for range ticker.C {
		rl.mu.Lock()
		now := time.Now()
		for key, entry := range rl.requests {
			if now.Sub(entry.windowStart) > rl.window {
				delete(rl.requests, key)
			}
		}
		rl.mu.Unlock()
	}
}

func (rl *RateLimiter) Middleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		key := c.ClientIP()

		rl.mu.Lock()
		entry, exists := rl.requests[key]
		now := time.Now()

		if !exists || now.Sub(entry.windowStart) > rl.window {
			entry = &rateLimitEntry{
				count:       1,
				windowStart: now,
			}
			rl.requests[key] = entry
			rl.mu.Unlock()
			c.Next()
			return
		}

		entry.count++
		if entry.count > rl.rate {
			rl.mu.Unlock()
			c.Header("Retry-After", "60")
			c.AbortWithStatusJSON(http.StatusTooManyRequests, gin.H{
				"code":    429,
				"message": "rate limit exceeded. try again later",
			})
			return
		}

		rl.mu.Unlock()
		c.Next()
	}
}
