package auth

import (
	"time"

	"github.com/dgrijalva/jwt-go"

	"github.com/sharpvik/mess/env"
)

const (
	CookieName = "mess-jwt"

	year             = time.Hour * 24 * 365
	issuer           = "mess-admin-issuer"
	envJWTSigningKey = "JWT_SIGNING_KEY"
)

func keyFunc(token *jwt.Token) (interface{}, error) {
	key, err := env.TryGet(envJWTSigningKey)
	return []byte(key), err
}

func mustGetSigningKey() (key []byte) {
	return []byte(env.MustGet(envJWTSigningKey))
}
