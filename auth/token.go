package auth

import (
	"net/http"
	"time"

	"github.com/dgrijalva/jwt-go"
)

type SignedToken string

func NewSignedJWTTokenWithClaimsForUser(handle string) (SignedToken, error) {
	claims := &Claims{
		UserHandle: handle,
		StdClaims: jwt.StandardClaims{
			ExpiresAt: time.Now().Add(year).Unix(),
			Issuer:    issuer,
		},
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	signature := mustGetSigningKey()
	signed, err := token.SignedString(signature)
	return SignedToken(signed), err
}

func (st SignedToken) WrapInCookie() *http.Cookie {
	return &http.Cookie{
		Name:     "jwt",
		Value:    string(st),
		HttpOnly: true,
		SameSite: http.SameSiteStrictMode,
	}
}

func (st SignedToken) ParseToken() (*jwt.Token, error) {
	return jwt.ParseWithClaims(string(st), &Claims{}, keyFunc)
}
