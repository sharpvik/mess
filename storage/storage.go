package storage

import "embed"

//go:embed *
var Storage embed.FS

const DefaultAvatar = "default-avatar.jpg"
