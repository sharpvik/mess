package configs

import (
	"flag"
	"os"

	"github.com/sharpvik/log-go"
)

// Config contains configuration information for the whole app.
type Config struct {
	Database Database
	Server   Server
}

// MustInit attempts to initialise Config and panics in case of failure.
func MustInit() (config Config) {
	log.Debug("config common")
	config.Database = mustInitDB()
	config.Server = mustInitServer()
	return
}

func mustGet(key string) (r string) {
	r = os.Getenv(key)
	if r == "" {
		log.Fatal("failed to get '%s'", key)
	}
	return
}

func parseFlags() (dev bool) {
	d := flag.Bool("dev", false, "run server in development mode")
	flag.Parse()
	return *d
}
