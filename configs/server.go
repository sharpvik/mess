package configs

import (
	"net/http"

	"github.com/sharpvik/log-go"

	"github.com/sharpvik/mess/env"
)

type Server struct {
	PublicDir http.Dir
	DevMode   bool
}

func mustInitServer() Server {
	log.Debug("config server")
	return Server{
		PublicDir: http.Dir(env.MustGet("CLIENT_DIR")),
		DevMode:   parseFlags(),
	}
}
