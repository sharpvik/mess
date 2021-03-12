package configs

import (
	"io/fs"
	"net/http"
	"os"

	"github.com/sharpvik/log-go"

	"github.com/sharpvik/mess/env"
)

type Server struct {
	DistDir    fs.FS
	StorageDir http.Dir
	DevMode    bool
}

func mustInitServer() Server {
	log.Debug("config server")
	return Server{
		DistDir:    os.DirFS(env.MustGet("CLIENT_DIST_DIR")),
		StorageDir: http.Dir(env.MustGet("STORAGE_DIR")),
		DevMode:    parseFlags(),
	}
}
