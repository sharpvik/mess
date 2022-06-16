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

func (st SignedToken) String() string {
	return string(st)
}

func (st SignedToken) WrapInCookie() *http.Cookie {
	return cookieWithValue(st.String())
}

func (st SignedToken) ParseToken() (*jwt.Token, error) {
	return jwt.ParseWithClaims(st.String(), &Claims{}, keyFunc)
}

func TokenFromRequestCookie(r *http.Request) (
	token *jwt.Token, status int, err error) {

	status = http.StatusOK

	cookie, err := r.Cookie(cookieName)
	if err != nil {
		err = fmt.Errorf("'%s' cookie not found: %s", cookieName, err)
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
