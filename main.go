package main

import (
	"github.com/joho/godotenv"
	"github.com/sharpvik/log-go/v2"

	"github.com/sharpvik/mess/configs"
	"github.com/sharpvik/mess/database"
	"github.com/sharpvik/mess/server"
)

func init() {
	log.SetLevel(log.LevelDebug)
	log.Debug("reading .env ...")
	if err := godotenv.Load(); err != nil {
		log.Error("failed to read .env")
	}
}

func mustInit() (config configs.Config, db *database.Database) {
	config = configs.MustInit()
	db = database.MustInit(config.Database)
	return
}

func main() {
	config, db := mustInit()
	log.Debug("init successfull")

	serv := server.NewServer(config.Server, db.Conn)
	done := make(chan bool, 1)
	go serv.ServeWithGrace(done)

	<-done
	log.Debug("server stopped")
}
