package server

import (
	"net/http"
	"path"

	"github.com/jmoiron/sqlx"

	"github.com/sharpvik/mux"
)

func newServerHandler(publicDir http.Dir, db *sqlx.DB) http.Handler {
	rtr := mux.New()

	rtr.Subrouter().
		PathPrefix("/api").
		// Methods may vary and are defined by the API handler.
		Handler(newAPI(db))

	rtr.Subrouter().
		PathPrefix("/@").
		Methods(http.MethodGet).
		HandleFunc(index(string(publicDir)))

	// Everything else goes to the file server.
	rtr.Subrouter().
		Methods(http.MethodGet).
		Handler(http.FileServer(publicDir))

	return rtr
}

// index sends client's index.html file in response to every request that starts
// with /@ (which signifies that this is an internal Elm routing URL).
func index(publicDir string) mux.View {
	return func(w http.ResponseWriter, r *http.Request) {
		http.ServeFile(w, r, path.Join(publicDir, "index.html"))
	}
}
