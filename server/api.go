package server

import (
	"encoding/json"
	"net/http"

	"github.com/jmoiron/sqlx"
	"github.com/sharpvik/log-go"
	"github.com/sharpvik/mux"

	"github.com/sharpvik/mess/auth"
	"github.com/sharpvik/mess/database/users"
	"github.com/sharpvik/mess/security"
)

type api struct {
	users users.Users
}

func newAPI(db *sqlx.DB) *api {
	return &api{
		users: users.NewUsers(db),
	}
}

func (db *api) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	rtr := mux.New()

	rtr.Subrouter().
		Path("/signup").
		Methods(http.MethodPost).
		HandleFunc(db.signup)

	rtr.Subrouter().
		Path("/login").
		Methods(http.MethodPost).
		HandleFunc(db.login)

	rtr.ServeHTTP(w, r)
}

func (db *api) signup(w http.ResponseWriter, r *http.Request) {
	user := new(users.User)
	json.NewDecoder(r.Body).Decode(user)

	log.Infof("adding new user %s ...", user.Handle)

	hash, salt, err := security.SaltedHash(user.Password)
	if err != nil {
		log.Errorf("failed to add user %s: %s", user.Handle, err)
		w.WriteHeader(http.StatusInternalServerError)
		return
	}
	user.Password = hash
	user.Salt = salt

	err = db.users.Add(user)
	if err != nil {
		log.Errorf("failed to add user %s: %s", user.Handle, err)
		w.WriteHeader(http.StatusBadRequest)
		return
	}

	log.Infof("user %s successfully added", user.Handle)
}

func (db *api) login(w http.ResponseWriter, r *http.Request) {
	user := new(users.User)
	json.NewDecoder(r.Body).Decode(user)

	log.Infof("processing login request from %s ...", user.Handle)
	// u has user data pulled from database.
	u, err := db.users.Get(user.Handle)
	if err != nil {
		log.Errorf("failed to access user's password info")
		w.WriteHeader(http.StatusBadRequest)
		return
	}

	if !security.CheckPasswordHash(user.Password, u.Password, u.Salt) {
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
