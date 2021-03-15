package users

// User row.
type User struct {
	Handle   string `json:"handle"`
	Name     string `json:"name"`
	Password string `db:"hash"`
	Salt     string `db:"salt"`
}

// Profile for user.
type Profile struct {
	Handle string `json:"handle"`
	Name   string `json:"name"`
}

func newProfile(user *User) *Profile {
	return &Profile{
		Handle: user.Handle,
		Name:   user.Name,
	}
}
