package server

import (
	"encoding/json"
	"fmt"
	"net/http"

	"github.com/jmoiron/sqlx"
	"github.com/sharpvik/log-go/v2"
	"github.com/sharpvik/mux"

	"github.com/sharpvik/mess/auth"
	"github.com/sharpvik/mess/database/chats"
	"github.com/sharpvik/mess/database/users"
	"github.com/sharpvik/mess/security"
)

type api struct {
	storage string
	users   users.Users
	chats   chats.Chats
}

func newAPI(db *sqlx.DB, storage http.Dir) http.Handler {
	i := &api{
		storage: string(storage),
		users:   users.NewUsers(db),
		chats:   chats.NewChats(db),
	}

	rtr := mux.New()

	rtr.Subrouter().
		Path("/signup").
		Methods(http.MethodPost).
		HandleFunc(i.signup)

	rtr.Subrouter().
		Path("/login").
		Methods(http.MethodPost).
		HandleFunc(i.login)

	rtr.Subrouter().
		Path("/chats").
		Methods(http.MethodGet).
		HandleFunc(i.listChats)

	rtr.Subrouter().
		Path("/profile").
		Methods(http.MethodGet).
		HandleFunc(i.profile)

	rtr.Subrouter().
		Path("/avatar").
		Methods(http.MethodGet).
		HandleFunc(i.avatar)

	return rtr
}

func (db *api) signup(w http.ResponseWriter, r *http.Request) {
	user := new(users.User)
	json.NewDecoder(r.Body).Decode(user)

	log.Infof("adding new user %s ...", user.Handle)

	hash, salt, err := security.SaltedHash(user.Password)
	if err != nil {
		log.Errorf("failed to add user %s: %s", user.Handle, err)
		w.WriteHeader(http.StatusInternalServerError)
		fmt.Fprint(w, "🙀 For some reason, I can't encrypt your password, but it has to be done for security purposes. Please, try to fill in the form again!")
		return
	}
	user.Password = hash
	user.Salt = salt

	err = db.users.Add(user)
	if err != nil {
		log.Errorf("failed to add user %s: %s", user.Handle, err)
		w.WriteHeader(http.StatusConflict)
		fmt.Fprintf(w, "🙀 Looks like some opportunist came before you and has reserved the '%s' username. Try to come up with something else!",
			user.Handle)
		return
	}

	cozyChatID := 1 // COZY CHAT is always the first chat in the database!
	err = db.chats.AddUserToChat(user.Handle, cozyChatID)
	if err != nil {
		log.Errorf("failed to add user %s to COZY CHAT: %s", user.Handle, err)
	}

	log.Infof("user %s successfully added", user.Handle)
	fmt.Fprintf(w, "🤠 Welcome to the family, %s!", user.Name)
}

func (db *api) login(w http.ResponseWriter, r *http.Request) {
	user := new(users.User)
	json.NewDecoder(r.Body).Decode(user)

	log.Infof("processing login request from %s ...", user.Handle)
	// u has user data pulled from database.
	u, err := db.users.Get(user.Handle)
	if err != nil {
		log.Errorf("failed to access user's password info")
		w.WriteHeader(http.StatusNotFound)
		fmt.Fprintf(w, "🙀 I looked through my records, and I couldn't find a user with username '%s' anywhere. Make sure you didn't make a typo!",
			user.Handle)
		return
	}

	if !security.CheckPasswordHash(user.Password, u.Password, u.Salt) {
		log.Error("invalid password")
		w.WriteHeader(http.StatusUnauthorized)
		fmt.Fprintf(w, "🙀 The human knows as '%s', has a different passphrase to what you've entered. Make sure you didn't make a typo!",
			user.Handle)
		return
	}

	token, err := auth.NewSignedJWTTokenWithClaimsForUser(user.Handle)
	if err != nil {
		log.Errorf("failed to create JWT token: %s", err)
		w.WriteHeader(http.StatusInternalServerError)
		fmt.Fprint(w, "🙀 I can't seem to generate an identifier for you... It's my fault and I'll try to fix this as soon as possible!")
		return
	}

	http.SetCookie(w, token.WrapInCookie())
	log.Info("login request approved")
	fmt.Fprintf(w, "🤠 Welcome back, %s!", u.Name)
}

func (db *api) listChats(w http.ResponseWriter, r *http.Request) {
	handle, status, err := auth.UserHandleFromRequestCookie(r)
	if err != nil {
		log.Error(err)
		w.WriteHeader(status)
		return
	}

	log.Infof("user '%s' is requesting their chats list", handle)
	db.getEncodeAndLog(w, func() (interface{}, error) {
		return db.chats.GetForUser(handle)
	})
}

func (db *api) profile(w http.ResponseWriter, r *http.Request) {
	handle, status, err := auth.UserHandleFromRequestCookie(r)
	if err != nil {
		log.Error(err)
		w.WriteHeader(status)
		return
	}

	log.Infof("user '%s' is requesting their profile", handle)
	db.getEncodeAndLog(w, func() (interface{}, error) {
		return db.users.GetProfile(handle)
	})
}

// avatar is expecting a request of the following form:
//
//     GET /api/avatar
//
// or
//
//     GET /api/avatar?handle=sharpvik
//
// The handle query parameter is optional. If it is not specified, we will try
// to establish the user's identity via the JWT token wrapped in a cookie (if it
// even exists at all).
func (db *api) avatar(w http.ResponseWriter, r *http.Request) {
	if handle := r.URL.Query().Get("handle"); handle != "" {
		db.avatarForUser(w, r, handle)
	} else {
		db.avatarFromUserToken(w, r)
	}
}
