package config

import (
	"log"
	"os"
)

var DB struct {
	Host     string
	Port     string
	User     string
	Password string
	Name     string
}

func init() {
	log.Print("config api")
	DB.Host = os.Getenv("DB_HOST")
	DB.Port = os.Getenv("DB_PORT")
	DB.User = os.Getenv("DB_USER")
	DB.Password = os.Getenv("DB_PASS")
	DB.Name = os.Getenv("DB_NAME")
}
