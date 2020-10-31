package main

import (
	"context"
	_ "github.com/lib/pq"
	"github.com/sharpvik/mess/api"
	"github.com/sharpvik/mess/config"
	"github.com/sharpvik/mess/static"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"
)

func main() {
	db := dbi.MustInit()
	defer db.Close()

	server := &http.Server{
		Addr:         ":" + config.Server.Port,
		Handler:      static.MustInit(),
		ReadTimeout:  5 * time.Second,
		WriteTimeout: 10 * time.Second,
		IdleTimeout:  15 * time.Second,
	}

	// Channels for graceful shutdown.
	done := make(chan bool, 1)

	// Spawn graceful shutdown handler thread.
	go grace(server, &done)

	log.Printf("serving at port %s", config.Server.Port)
	if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		log.Fatal(err)
	}

	<-done
	log.Print("server stopped")
}

// Graceful shutdown handler.
func grace(server *http.Server, done *chan bool) {
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)

	<-quit
	log.Print("stopping server...")

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	server.SetKeepAlivesEnabled(false)

	if err := server.Shutdown(ctx); err != nil {
		log.Fatal("graceful shutdown failed")
	}

	close(*done)
}
