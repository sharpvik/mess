package server

import (
	"net/http"

	"github.com/jmoiron/sqlx"

	"github.com/sharpvik/log-go"
	"github.com/sharpvik/mess/configs"
	"github.com/sharpvik/mux"
)

func newServerHandler(config configs.Server, db *sqlx.DB) http.Handler {
	rtr := mux.New()

	// API.
	rtr.Subrouter().
		PathPrefix("/api").
		// Methods may vary and are defined by the API handler.
		Handler(newAPI(db, config.StorageDir))

	// Virtual routing in Elm.
	rtr.Subrouter().
		UseFunc(logRequest).
		PathPrefix("/@").
		Methods(http.MethodGet).
		HandleFunc(index(config.DistDir))

	// Everything else goes to the file server.
	rtr.Subrouter().
		Methods(http.MethodGet).
		Handler(http.FileServer(http.FS(config.DistDir)))

	return rtr
}

func logRequest(_ http.ResponseWriter, r *http.Request) {
	log.Infof("%s %s", r.Method, r.URL.String())
}
