package config

import (
	"log"
	"os"
)

var Server struct {
	Port string
}

func init() {
	log.Print("config server")
	Server.Port = os.Getenv("SERV_PORT")
}
