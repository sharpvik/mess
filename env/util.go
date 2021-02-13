package env

import (
	"fmt"
	"os"

	"github.com/sharpvik/log-go"
)

func MustGet(key string) (val string) {
	if val = os.Getenv(key); val == "" {
		log.Fatalf("failed to load key from environment: %s", key)
	}
	return
}

func TryGet(key string) (val string, err error) {
	if val = os.Getenv(key); val == "" {
		err = fmt.Errorf("failed to load key from environment: %s", key)
	}
	return
}
