package auth

import (
	"time"

	"github.com/dgrijalva/jwt-go"
)

func NewSignedJWTTokenWithClaimsForUser(handle string) (string, error) {
	claims := &Claims{
		UserHandle: handle,
		StdClaims: jwt.StandardClaims{
			ExpiresAt: time.Now().Add(year).Unix(),
			Issuer:    issuer,
		},
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	signature := mustGetSigningKey()
	return token.SignedString(signature)
}

func ParseToken(signed string) (*jwt.Token, error) {
	return jwt.ParseWithClaims(signed, &Claims{}, keyFunc)
}
