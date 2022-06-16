package migrations

import (
	"embed"
	"io/fs"
	"strings"
)

//go:embed *.sql
var migrations embed.FS

// FilterUpMigrations returns only migration entries ending with ".up.sql".
func FilterUpMigrations() (up []fs.DirEntry, err error) {
	migrations, err := migrations.ReadDir(".")
	if err != nil {
		return
	}

	for _, file := range migrations {
		if isUpMigration(file.Name()) {
			up = append(up, file)
		}
	}

	return
}

// ReadFile takes file name to read from migrations.
func ReadFile(name string) ([]byte, error) {
	return migrations.ReadFile(name)
}

func isUpMigration(filename string) bool {
	return strings.HasSuffix(filename, ".up.sql")
}
