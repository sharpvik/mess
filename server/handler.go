package server

import (
	"net/http"
	"path"

	"github.com/jmoiron/sqlx"
	"github.com/sharpvik/mess/database/users"
	"github.com/sharpvik/mux"
)

func newServerHandler(publicDir http.Dir, db *sqlx.DB) http.Handler {
	r := mux.New()
	api(r.Subrouter().PathPrefix("/api"), db)
	r.Subrouter().
		PathPrefix("/@").
		HandleFunc(index(string(publicDir)))
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
	r.Subrouter().
		Path("/login").
		Methods(http.MethodPost).
		HandleFunc(db.login())
}

func index(publicDir string) mux.View {
	return func(w http.ResponseWriter, r *http.Request) {
		http.ServeFile(w, r, path.Join(publicDir, "index.html"))
	}
}

func fileServer(dir http.Dir) http.Handler {
	return http.FileServer(dir)
}
