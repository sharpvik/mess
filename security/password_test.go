package security

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestHashAndComapre(t *testing.T) {
	password := "password123"
	hash, salt, err := SaltedHash(password)
	assert.NoError(t, err, "unexpected error while salting")
	assert.NotEmpty(t, salt, "salt was not provided")
	assert.True(t, CheckPasswordHash(password, hash, salt),
		"password was correct but did not pass check")
}

func TestBreachAttempt(t *testing.T) {
	password := "password123"
	attempt := "password12"
	hash, salt, err := SaltedHash(password)
	assert.NoError(t, err, "unexpected error while salting")
	assert.False(t, CheckPasswordHash(attempt, hash, salt),
		"password was incorrect but passed the check")
}
