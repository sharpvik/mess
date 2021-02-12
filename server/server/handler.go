package server

import (
	"net/http"
)

func newServerHandler(publicDir http.Dir) http.Handler {
	return fileServer(publicDir)
}
