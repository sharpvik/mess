package users

// User row.
type User struct {
	Handle   string
	Name     string
	Password string `db:"hash"`
	Salt     string
}
