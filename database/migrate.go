package database

import (
	"fmt"
	"io/ioutil"
	"path"
	"strings"

	"github.com/jmoiron/sqlx"
	_ "github.com/lib/pq" // the DB driver
	"github.com/sharpvik/log-go"

	"github.com/sharpvik/mess/server/configs"
)

// Database represents the generic database interface.
type Database struct {
	Conn   *sqlx.DB
	Config configs.Database
}

// MustInit attempts to connect to the database and panics in case of failure.
func MustInit(config configs.Database) (db *Database) {
	var err error

	details := fmt.Sprintf(
		"host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		config.Host, config.Port, config.User, config.Password, config.Name)

	dbi, err := sqlx.Connect("postgres", details)
	if err != nil {
		log.Error(err)
		log.Fatal("failed to connect to the database")
	}

	db = &Database{
		Conn:   dbi,
		Config: config,
	}

	db.up()

	return
}

func (db *Database) up() {
	migrations, err := ioutil.ReadDir(db.Config.Migrations)
	if err != nil {
		log.Fatal(err)
	}

	log.Debug("applying migrations ...")
	for _, file := range migrations {
		filename := file.Name()
		filepath := path.Join(db.Config.Migrations, filename)

		if !isUpMigration(filename) {
			continue
		}

		log.Debug(filename)
		if err := readAndApply(db.Conn, filepath); err != nil {
			log.Fatal(err)
		}
	}
}

func isUpMigration(filename string) bool {
	return strings.HasSuffix(filename, ".up.sql")
}

// readAndApply reads migration from file and applies it over the database
// connection.
func readAndApply(conn *sqlx.DB, path string) (err error) {
	migration, err := ioutil.ReadFile(path)
	if err != nil {
		return
	}
	_, err = conn.Exec(string(migration))
	return
}
