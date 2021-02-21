package server

import (
	"encoding/json"
	"net/http"

	"github.com/sharpvik/log-go"
	"github.com/sharpvik/mux"

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
