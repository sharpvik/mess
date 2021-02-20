package users

import (
	"database/sql"

	"github.com/jmoiron/sqlx"
)

// Users service.
type Users interface {
	// Add new User to Database.
	Add(*User) error
}

// Repo specification.
type Repo interface {
	NamedExec(string, interface{}) (sql.Result, error)
}

// User row.
type User struct {
	Handle string
	Name   string
	Hash   string `json:"password"`
	Salt   string
}

// users implements Users.
type users struct {
	repo Repo
}

// HashPassword with the specified generator function.
func (u *User) HashPassword(gen func(string) (string, string, error)) (err error) {
	hash, salt, err := gen(u.Hash)
	if err != nil {
		return
	}
	u.Hash = hash
	u.Salt = salt
	return
}

// NewUsers returns new instance of the Users interface.
func NewUsers(db *sqlx.DB) Users {
	return &users{db}
}

func (u *users) Add(user *User) (err error) {
	_, err = u.repo.NamedExec(
		`INSERT INTO users (handle, name, hash, salt)
		VALUES (:handle, :name, :hash, :salt)`, user)
	return
}
