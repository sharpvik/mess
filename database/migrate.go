package database

import (
	"errors"
	"fmt"
	"time"

	"github.com/jmoiron/sqlx"
	_ "github.com/lib/pq" // the DB driver
	"github.com/sharpvik/log-go"

	"github.com/sharpvik/mess/configs"
	"github.com/sharpvik/mess/migrations"
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

	dbi, err := connect(details, 10)
	if err != nil {
		log.Fatal("failed to connect to the database")
	}

	db = &Database{
		Conn:   dbi,
		Config: config,
	}

	db.up()
	return
}

// connect attempts to connect to the database given a threshold of allowed
// tries. As soon as there are no more tries left, it returns an error.
func connect(details string, tries int) (dbi *sqlx.DB, err error) {
	if tries < 1 {
		err = errors.New("database connection attempts limit reached")
		return
	}
	dbi, err = sqlx.Connect("postgres", details)
	if err != nil {
		log.Error(err)
		log.Debug("retrying in a second ...")
		time.Sleep(1 * time.Second)
		return connect(details, tries-1)
	}
	return
}

// up only applies migrations ending with ".up.sql".
func (db *Database) up() {
	migrations, err := migrations.FilterUpMigrations()
	if err != nil {
		log.Fatalf("failed to list up migrations: %s", err)
		return
	}

	log.Debug("applying migrations ...")
	for _, file := range migrations {
		if err := readAndApply(db.Conn, file.Name()); err != nil {
			log.Fatal(err)
		}
	}
}

func readAndApply(conn *sqlx.DB, path string) (err error) {
	log.Debug(path)
	migration, err := migrations.ReadFile(path)
	if err != nil {
		return
	}
	_, err = conn.Exec(string(migration))
	return
}
