package server

import (
	"net/http"

	"github.com/jmoiron/sqlx"
	"github.com/sharpvik/mux"

	"github.com/sharpvik/mess/auth"
	"github.com/sharpvik/mess/configs"
)

// newServerHandler returns the main server handler responsible for the API, and
// static assets delivery.
func newServerHandler(config configs.Server, db *sqlx.DB) http.Handler {
	rtr := mux.New()

	// API has to know whether this request comes from a Guest or an
	// authenticated user. Hence, why we use auth.Auth middleware.
	rtr.Subrouter().
		UseFunc(auth.Auth).
		UseFunc(logRequest("/api")).
		PathPrefix("/api").
		// Methods may vary and are defined by the API handler.
		Handler(newAPI(db, config.StorageDir))

	// Virtual routing in Elm.
	rtr.Subrouter().
		PathPrefix("/@").
		Methods(http.MethodGet).
		HandleFunc(index(config.DistDir))

	// Everything else goes to the file server.
	rtr.Subrouter().
		Methods(http.MethodGet).
		Handler(http.FileServer(http.FS(config.DistDir)))

	return rtr
}
