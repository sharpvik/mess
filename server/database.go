package server

import (
	"encoding/json"
	"net/http"

	"github.com/sharpvik/log-go"
	"github.com/sharpvik/mux"

	"github.com/sharpvik/mess/auth"
	"github.com/sharpvik/mess/database/users"
	"github.com/sharpvik/mess/security"
)

type database struct {
	users users.Users
}

func (db *database) signup() mux.View {
	return func(w http.ResponseWriter, r *http.Request) {
		user := new(users.User)
		json.NewDecoder(r.Body).Decode(user)

		log.Infof("adding new user %s ...", user.Handle)

		err := user.HashPassword(security.SaltedHash)
		if err != nil {
			log.Errorf("failed to add user %s: %s", user.Handle, err)
			w.WriteHeader(http.StatusInternalServerError)
			return
		}

		err = db.users.Add(user)
		if err != nil {
			log.Errorf("failed to add user %s: %s", user.Handle, err)
			w.WriteHeader(http.StatusBadRequest)
			return
		}

		log.Infof("user %s successfully added", user.Handle)
	}
}

func (db *database) login() mux.View {
	return func(w http.ResponseWriter, r *http.Request) {
		user := new(users.User)
		json.NewDecoder(r.Body).Decode(user)

		log.Infof("processing login request from %s ...", user.Handle)
		hash, salt, err := db.users.GetHashAndSalt(user)
		if err != nil {
			log.Errorf("failed to access user's password info")
			w.WriteHeader(http.StatusBadRequest)
			return
		}

		if !security.CheckPasswordHash(user.Password, hash, salt) {
			log.Error("invalid password")
			w.WriteHeader(http.StatusUnauthorized)
			return
		}

		token, err := auth.NewSignedJWTTokenWithClaimsForUser(user.Handle)
		if err != nil {
			log.Errorf("failed to create JWT token: %s", err)
			w.WriteHeader(http.StatusInternalServerError)
			return
		}

		http.SetCookie(w, token.WrapInCookie())
		log.Info("login request approved")
	}
}
