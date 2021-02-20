package server

import (
	"net/http"

	"github.com/jmoiron/sqlx"
	"github.com/sharpvik/mess/database/users"
	"github.com/sharpvik/mux"
)

func newServerHandler(publicDir http.Dir, db *sqlx.DB) http.Handler {
	r := mux.New()
	api(r.Subrouter().PathPrefix("/api"), db)
	r.Subrouter().
		Methods(http.MethodGet).
		Handler(fileServer(publicDir))
	return r
}

func api(r *mux.Router, conn *sqlx.DB) {
	db := &database{
		users: users.NewUsers(conn),
	}
	r.Subrouter().
		Path("/signup").
		Methods(http.MethodPost).
		HandleFunc(db.signup())
}

func fileServer(dir http.Dir) http.Handler {
	return http.FileServer(dir)
}
