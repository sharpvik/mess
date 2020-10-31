package dbi

import (
	"fmt"
	"github.com/jmoiron/sqlx"
	"github.com/sharpvik/mess/config"
	"log"
)

func MustInit() (db *sqlx.DB) {
	var err error

	details := fmt.Sprintf(
		"host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		config.DB.Host, config.DB.Port, config.DB.User,
		config.DB.Password, config.DB.Name)

	db, err = sqlx.Connect("postgres", details)
	if err != nil {
		log.Fatal("database login details are invalid; failed to connect")
	}

	return
}
