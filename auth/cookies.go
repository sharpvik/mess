package auth

import "net/http"

const cookieName = "mess-jwt"

func UserHandleFromRequestCookie(r *http.Request) (
	handle string, status int, err error) {

	token, status, err := TokenFromRequestCookie(r)
	if err != nil {
		return
	}

	handle = token.Claims.(*Claims).UserHandle
	return
}

func EmptyCookie() *http.Cookie {
	return &http.Cookie{
		Name:     cookieName,
		Value:    "",
		HttpOnly: true,
		SameSite: http.SameSiteStrictMode,
	}
}

func cookieWithValue(value string) (cookie *http.Cookie) {
	cookie = EmptyCookie()
	cookie.Value = value
	return
}
