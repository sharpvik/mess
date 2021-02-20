package server

import (
	"github.com/sharpvik/log-go"
)

// setMode takes a boolean flag called devMode and uses it to decide on the
// proper server mode.
func (s *Server) setMode(devMode bool) {
	var mode string
	if devMode {
		mode = s.toDevServer()
	} else {
		mode = s.toProdServer()
	}
	log.Debugf("server running in %s mode ...", mode)
}

// toDevServer returns a server that runs on localhost port 8080.
func (s *Server) toDevServer() string {
	s.server.Addr = "127.0.0.1:8000"
	return "development"
}

// toProdServer returns a server that will be listening on the publically
// available standard HTTP port.
func (s *Server) toProdServer() string {
	s.server.Addr = "0.0.0.0:80"
	return "production"
}
