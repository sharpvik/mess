package auth

import (
	"context"
	"errors"
	"net/http"

	"github.com/dgrijalva/jwt-go"
)

type authKey string

const contextMessJWTKey = authKey(cookieName)

func Auth(_ http.ResponseWriter, r *http.Request) {
	token, _, err := TokenFromRequestCookie(r)
	if err != nil {
		return
	}
	withContext := r.Clone(context.WithValue(r.Context(),
		contextMessJWTKey, token))
	swapRequest(r, withContext)
}

func IsAuth(r *http.Request) (handle string, err error) {
	if token, ok := r.Context().Value(contextMessJWTKey).(*jwt.Token); ok {
		handle = token.Claims.(*Claims).UserHandle
		return
	}
	err = errors.New("unauthorized")
	return
}

func swapRequest(this *http.Request, another *http.Request) {
	*this = *another
}
