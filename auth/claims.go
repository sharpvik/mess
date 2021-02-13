package auth

import (
	"errors"

	"github.com/dgrijalva/jwt-go"
)

type Claims struct {
	UserHandle string `json:"handle"`
	StdClaims  jwt.StandardClaims
}

func (claims *Claims) Valid() (err error) {
	if err = claims.StdClaims.Valid(); err != nil {
		return
	}
	if !claims.StdClaims.VerifyIssuer(issuer, true) {
		return errors.New("invalid issuer")
	}
	return
}
