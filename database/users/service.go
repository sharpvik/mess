package users

// Users service.
type Users interface {
	// Add new User to Database.
	Add(*User) error

	// GetHash of this user's password.
	Get(string) (*User, error)
}

// User row.
type User struct {
	Handle   string
	Name     string
	Password string `db:"hash"`
	Salt     string
}
