package server

import (
	"net/http"
)

func fileServer(dir http.Dir) http.Handler {
	return http.FileServer(dir)
}

func newServerHandler(publicDir http.Dir) http.Handler {
	return fileServer(publicDir)
}
