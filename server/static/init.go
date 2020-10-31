package static

import (
	"github.com/sharpvik/mess/config"
	"net/http"
)

func MustInit() (fs http.Handler) {
	return http.StripPrefix("/pub/",
		http.FileServer(http.Dir(config.Path.Public)))
}
