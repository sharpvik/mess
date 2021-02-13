package configs

import (
	"net/http"

	"github.com/sharpvik/log-go"
)

type Server struct {
	PublicDir http.Dir
	DevMode   bool
}

func mustInitServer() Server {
	log.Debug("config server")
	return Server{
		PublicDir: http.Dir(mustGet("CLIENT_DIR")),
		DevMode:   parseFlags(),
	}
}
