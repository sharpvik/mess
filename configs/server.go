package configs

import (
	"flag"
	"io/fs"
	"os"

	"github.com/sharpvik/log-go/v2"

	"github.com/sharpvik/mess/env"
)

type Server struct {
	DistDir fs.FS
	DevMode bool
}

func mustInitServer() Server {
	log.Debug("config server")
	return Server{
		DistDir: os.DirFS(env.MustGet("CLIENT_DIST_DIR")),
		DevMode: parseFlags(),
	}
}

func parseFlags() (dev bool) {
	d := flag.Bool("dev", false, "run server in development mode")
	flag.Parse()
	return *d
}
