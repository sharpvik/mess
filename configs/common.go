package configs

import "github.com/sharpvik/log-go/v2"

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
