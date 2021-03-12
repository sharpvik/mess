package server

import (
	"bytes"
	"io"
	"io/fs"
	"net/http"
	"time"

	"github.com/sharpvik/log-go"

	"github.com/sharpvik/mux"
)

// index sends client's index.html file in response to every request that starts
// with /@ (which signifies that this is an internal Elm routing URL).
func index(dist fs.FS) mux.View {
	return func(w http.ResponseWriter, r *http.Request) {
		serveFileByNameFS(w, r, dist, "index.html")
	}
}

func serveFileByNameFS(w http.ResponseWriter, r *http.Request, fsys fs.FS, name string) {
	if file, err := fsys.Open(name); err == nil {
		serveFileFS(w, r, file)
	} else {
		log.Errorf("failed to serve %s", name)
		w.WriteHeader(http.StatusInternalServerError)
	}
}

func serveFileFS(w http.ResponseWriter, r *http.Request, file fs.File) {
	rs, err := makeReadSeekerFromFileFS(file)
	if err != nil {
		log.Error(err)
		w.WriteHeader(http.StatusInternalServerError)
		return
	}
	stat, err := file.Stat()
	name := stat.Name()
	var modtime time.Time
	if err != nil {
		log.Error(err)
		modtime = time.Now()
	} else {
		modtime = stat.ModTime()
	}
	http.ServeContent(w, r, name, modtime, rs)
}

func makeReadSeekerFromFileFS(file fs.File) (rs io.ReadSeeker, err error) {
	stat, err := file.Stat()
	if err != nil {
		return
	}
	content := make([]byte, stat.Size())
	n, err := file.Read(content)
	if err != nil {
		return
	}
	log.Debugf("read %d bytes from file", n)
	rs = bytes.NewReader(content)
	return
}
