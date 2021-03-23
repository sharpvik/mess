package server

import (
	"net/http"

	"github.com/sharpvik/log-go/v2"

	"github.com/sharpvik/mess/storage"
)

func (db *api) avatarForUser(w http.ResponseWriter, r *http.Request, handle string) {
	log.Infof("user '%s' is requesting their avatar", handle)
	serveFileByNameFS(w, r, storage.Storage, storage.DefaultAvatar)
}

func unauthorizedHandler(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusUnauthorized)
}
