package config

import (
	"github.com/joho/godotenv"
	"log"
)

func init() {
	log.Print("config godotenv")
	err := godotenv.Load()
	if err != nil {
		log.Fatal("failed to load env")
	}
}
