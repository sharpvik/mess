package users

import (
	"github.com/jmoiron/sqlx"
)

// users implements Users.
type users struct {
	db *sqlx.DB
}

// NewUsers returns new instance of the Users interface.
func NewUsers(db *sqlx.DB) Users {
	return &users{db}
}

func (u *users) Add(user *User) (err error) {
	_, err = u.db.Exec(
		`INSERT INTO users (handle, name, hash, salt)
		VALUES ($1, $2, $3, $4)`,
		user.Handle, user.Name, user.Password, user.Salt)
	return
}

func (u *users) Get(handle string) (user *User, err error) {
	user = new(User)
	err = u.db.Get(user,
		`SELECT handle, name, hash, salt FROM users WHERE handle = $1`, handle)
	return
}

func (u *users) GetProfile(handle string) (profile *Profile, err error) {
	user, err := u.Get(handle)
	if err != nil {
		return
	}
	profile = newProfile(user)
	return
}

func (u *users) UpdateProfile(handle string, update *User) (err error) {
	_, err = u.db.Exec(
		`UPDATE users 
		SET handle = $1, name = $2, hash = $3, salt = $4
		WHERE handle = $5`,
		update.Handle, update.Name, update.Password, update.Salt, handle)
	return
}
