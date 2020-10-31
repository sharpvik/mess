package chat

import "github.com/jmoiron/sqlx"

type Chat struct {
	ID   int
	Name string
}

func SelectAll(db *sqlx.DB) (chats []Chat, err error) {
	err = db.Select(&chats, "SELECT * FROM chats")
	return
}
