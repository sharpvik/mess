package server

import (
	"encoding/json"
	"fmt"
	"net/http"
	"path"

	"github.com/sharpvik/log-go/v2"
	"github.com/sharpvik/mess/auth"
)

// Getter should be a closure that can return to us some data to encode or an
// error in case of failure.
type Getter func() (interface{}, error)

func (db *api) getAndEncode(w http.ResponseWriter, getter Getter) (err error) {
	data, err := getter()
	if err != nil {
		err = fmt.Errorf("failed to fetch: %s", err)
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	err = json.NewEncoder(w).Encode(data)
	if err != nil {
		err = fmt.Errorf("failed to encode: %s", err)
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	return
}

func (db *api) getEncodeAndLog(w http.ResponseWriter, getter Getter) {
	err := db.getAndEncode(w, getter)
	if err != nil {
		log.Error(err)
	}
}

func (db *api) avatarForUser(w http.ResponseWriter, r *http.Request, handle string) {
	log.Infof("user '%s' is requesting their avatar", handle)
	http.ServeFile(w, r, path.Join(db.storage, "defaults", "avatar.jpg"))
}

func (db *api) avatarFromUserToken(w http.ResponseWriter, r *http.Request) {
	handle, status, err := auth.UserHandleFromRequestCookie(r)
	if err != nil {
		log.Error(err)
		w.WriteHeader(status)
		return
	}
	db.avatarForUser(w, r, handle)
}
