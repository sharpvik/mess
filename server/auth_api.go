package server

import (
	"encoding/json"
	"net/http"

	"github.com/sharpvik/log-go/v2"
	"github.com/sharpvik/mux"

	"github.com/sharpvik/mess/auth"
	"github.com/sharpvik/mess/database/users"
	"github.com/sharpvik/mess/security"
)

type authorizedAPI struct {
	handle string
	api    *api
}

func (db *api) newAuthorizedHandler(handle string) http.Handler {
	ai := &authorizedAPI{
		handle: handle,
		api:    db,
	}

	rtr := mux.New()

	rtr.Subrouter().
		Path("/chats").
		Methods(http.MethodGet).
		HandleFunc(ai.listChats)

	rtr.Subrouter().
		Path("/profile").
		Methods(http.MethodGet).
		HandleFunc(ai.profile)

	rtr.Subrouter().
		Path("/profile").
		Methods(http.MethodPost).
		HandleFunc(ai.updateProfile)

	rtr.Subrouter().
		Path("/avatar").
		Methods(http.MethodGet).
		HandleFunc(ai.avatar)

	rtr.Subrouter().
		Path("/logout").
		Methods(http.MethodGet).
		HandleFunc(ai.logout)

	return rtr
}

func (db *authorizedAPI) listChats(w http.ResponseWriter, r *http.Request) {
	log.Infof("user '%s' is requesting their chats list", db.handle)
	db.getEncodeAndLog(w, func() (interface{}, error) {
		return db.api.chats.GetForUser(db.handle)
	})
}

func (db *authorizedAPI) profile(w http.ResponseWriter, r *http.Request) {
	log.Infof("user '%s' is requesting their profile", db.handle)
	db.getEncodeAndLog(w, func() (interface{}, error) {
		return db.api.users.GetProfile(db.handle)
	})
}

func (db *authorizedAPI) updateProfile(w http.ResponseWriter, r *http.Request) {
	log.Infof("user '%s' is requesting to update their profile", db.handle)
	update := new(users.ProfileUpdate)
	err := json.NewDecoder(r.Body).Decode(update)
	if err != nil {
		log.Errorf("failed to update profile: %s", err)
		w.WriteHeader(http.StatusBadRequest)
		return
	}

	hash, salt, err := security.SaltedHash(update.Password)
	if err != nil {
		log.Errorf("failed to update profile: %s", err)
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	user := &users.User{
		Handle:   update.Handle,
		Name:     update.Name,
		Password: hash,
		Salt:     salt,
	}

	err = db.api.users.UpdateProfile(db.handle, user)
	if err != nil {
		log.Errorf("failed to update profile: %s", err)
		w.WriteHeader(http.StatusConflict)
		return
	}
}

func (db *authorizedAPI) avatar(w http.ResponseWriter, r *http.Request) {
	db.api.avatarForUser(w, r, db.handle)
}

func (db *authorizedAPI) logout(w http.ResponseWriter, r *http.Request) {
	http.SetCookie(w, auth.EmptyCookie())
}
