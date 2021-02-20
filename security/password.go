package security

import (
	"crypto/rand"

	"golang.org/x/crypto/bcrypt"
)

// SaltedHash returns a salted hash + salt from plain string.
func SaltedHash(password string) (hash string, salt string, err error) {
	salt = randomSaltWithByteSize(8)
	saltedPassword := salt + password
	bytes, err := bcrypt.GenerateFromPassword([]byte(saltedPassword), 14)
	return string(bytes), salt, err
}

// CheckPasswordHash validates password based on hash and salt.
func CheckPasswordHash(password, hash, salt string) bool {
	saltedPassword := salt + password
	err := bcrypt.CompareHashAndPassword([]byte(hash), []byte(saltedPassword))
	return err == nil
}

func randomSaltWithByteSize(size uint) string {
	buf := make([]byte, size)
	rand.Read(buf)
	return string(buf)
}
