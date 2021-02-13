package auth

import (
	"os"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestParseToken(t *testing.T) {
	os.Setenv(envJWTSigningKey, "sharpvik-signature")
	signed, err := NewSignedJWTTokenWithClaimsForUser("sharpvik")

	assert.NoErrorf(t, err, "failed to create the token: %s", err)

	token, err := ParseToken(signed)

	assert.NoErrorf(t, err, "failed to parse the token: %s", err)
	assert.NoError(t, token.Claims.Valid(), "claims should be valid")
	assert.True(t, token.Claims.(*Claims).StdClaims.VerifyIssuer(issuer, true),
		"issuer should be valid")
}
