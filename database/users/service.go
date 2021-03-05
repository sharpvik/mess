package users

// Users service.
type Users interface {
	// Add new User to Database.
	Add(*User) error

	// Get all user info by handle.
	Get(string) (*User, error)

	/* Methods that return json.Marshaler are here to separate concerns. */

	// GetProfile by handle.
	GetProfile(string) (*Profile, error)
}
