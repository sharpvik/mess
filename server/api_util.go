package server

import (
	"encoding/json"
	"fmt"
	"net/http"

	"github.com/sharpvik/log-go"
)

// Getter should be a closure that can return to us some data to encode or an
// error in case of failure.
type Getter func() (interface{}, error)

func (db *api) getAndEncode(w http.ResponseWriter, getter Getter) (err error) {
	data, err := getter()
	if err != nil {
		err = fmt.Errorf("failed to fetch: %s", err)
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	err = json.NewEncoder(w).Encode(data)
	if err != nil {
		err = fmt.Errorf("failed to encode: %s", err)
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	return
}

func (db *api) getEncodeAndLog(w http.ResponseWriter, getter Getter) {
	err := db.getAndEncode(w, getter)
	if err != nil {
		log.Error(err)
	}
}
