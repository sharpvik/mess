package users

import (
	"database/sql"

	"github.com/jmoiron/sqlx"
)

// Repo specification.
type Repo interface {
	NamedExec(string, interface{}) (sql.Result, error)
	QueryRowx(query string, args ...interface{}) *sqlx.Row
}

// Users service.
type Users interface {
	// Add new User to Database.
	Add(*User) error

	// GetHash of this user's password.
	GetHashAndSalt(*User) (string, string, error)
}

// User row.
type User struct {
	Handle   string
	Name     string
	Password string
	Salt     string
}

// users implements Users.
type users struct {
	repo Repo
}

// HashPassword with the specified generator function.
func (u *User) HashPassword(gen func(string) (string, string, error)) (err error) {
	hash, salt, err := gen(u.Password)
	if err != nil {
		return
	}
	u.Password = hash
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
		VALUES (:handle, :name, :password, :salt)`, user)
	return
}

func (u *users) GetHashAndSalt(user *User) (hash, salt string, err error) {
	row := u.repo.QueryRowx(
		`SELECT hash, salt FROM users WHERE handle = $1`, user.Handle)
	err = row.Scan(&hash, &salt)
	return
}
