package users

import (
	"database/sql"
)

// Users service.
type Users interface {
	// Add new User to Database.
	Add(*User) error

	// GetHash of this user's password.
	Get(string) (*User, error)
}

// Repo specification.
type Repo interface {
	NamedExec(string, interface{}) (sql.Result, error)
	Exec(string, ...interface{}) (sql.Result, error)
	Get(dest interface{}, query string, args ...interface{}) error
}
