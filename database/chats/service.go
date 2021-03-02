package chats

// Chats service.
type Chats interface {
	AddUserToChat(handle string, chat int) error
	GetForUser(handle string) ([]string, error)
}
