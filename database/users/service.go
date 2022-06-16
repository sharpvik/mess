package users

// Users service.
type Users interface {
	// Add new User to Database.
	Add(*User) error

	// Get all user info by handle.
	Get(string) (*User, error)

	// GetProfile by handle.
	GetProfile(string) (*Profile, error)

	// UpdateProfile for user with given handle
	UpdateProfile(string, *User) error
}
