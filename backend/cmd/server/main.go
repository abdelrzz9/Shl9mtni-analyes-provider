package main

import (
	"fmt"
	"log"

	"github.com/abdelrzz9/math_app/backend/internal/config"
	"github.com/abdelrzz9/math_app/backend/internal/router"
)

func main() {
	cfg := config.Load()

	r := router.SetupRouter(cfg)

	addr := fmt.Sprintf(":%s", cfg.Port)
	log.Printf("Starting server on %s", addr)
	if err := r.Run(addr); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}
