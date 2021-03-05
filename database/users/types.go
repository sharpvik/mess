package users

// User row.
type User struct {
	Handle   string
	Name     string
	Password string `db:"hash"`
	Salt     string
}

// Profile for user.
type Profile struct {
	Handle string
	Name   string
}

func newProfile(user *User) *Profile {
	return &Profile{
		Handle: user.Handle,
		Name:   user.Name,
	}
}
