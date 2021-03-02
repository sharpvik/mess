package chats

import "github.com/jmoiron/sqlx"

type chats struct {
	db *sqlx.DB
}

func NewChats(db *sqlx.DB) Chats {
	return &chats{db}
}

func (c *chats) AddUserToChat(handle string, chat int) (err error) {
	_, err = c.db.Exec(
		`INSERT INTO members (handle, chat) VALUES ($1, $2)`, handle, chat)
	return
}

func (c *chats) GetForUser(handle string) (names []string, err error) {
	err = c.db.Select(&names,
		`SELECT name FROM chats CROSS JOIN members WHERE handle = $1`, handle)
	return
}
