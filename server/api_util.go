package server

import (
	"net/http"
	"path"

	"github.com/sharpvik/log-go/v2"
)

func (db *api) avatarForUser(w http.ResponseWriter, r *http.Request, handle string) {
	log.Infof("user '%s' is requesting their avatar", handle)
	http.ServeFile(w, r, path.Join(db.storage, "defaults", "avatar.jpg"))
}
