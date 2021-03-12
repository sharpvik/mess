package auth

import (
	"fmt"
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
		Name:     CookieName,
		Value:    string(st),
		HttpOnly: true,
		SameSite: http.SameSiteStrictMode,
	}
}

func (st SignedToken) ParseToken() (*jwt.Token, error) {
	return jwt.ParseWithClaims(string(st), &Claims{}, keyFunc)
}

func TokenFromRequestCookie(r *http.Request) (
	token *jwt.Token, status int, err error) {

	status = http.StatusOK

	cookie, err := r.Cookie(CookieName)
	if err != nil {
		err = fmt.Errorf("jwt token cookie not found: %s", err)
		status = http.StatusUnauthorized
		return
	}

	token, err = SignedToken(cookie.Value).ParseToken()
	if err != nil {
		err = fmt.Errorf(
			"unauthorised request: invaild token: %s", err)
		status = http.StatusUnauthorized
		return
	}

	if !token.Valid {
		err = fmt.Errorf("unauthorised request: invaild token")
		status = http.StatusUnauthorized
		return
	}

	return
}

func UserHandleFromRequestCookie(r *http.Request) (
	handle string, status int, err error) {

	token, status, err := TokenFromRequestCookie(r)
	if err != nil {
		return
	}

	handle = token.Claims.(*Claims).UserHandle
	return
}
