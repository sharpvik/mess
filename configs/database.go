package configs

import (
	"github.com/sharpvik/log-go"

	"github.com/sharpvik/mess/env"
)

type Database struct {
	Host       string
	Port       string
	User       string
	Password   string
	Name       string
	Migrations string
}

func mustInitDB() Database {
	log.Debug("config database")
	return Database{
		Host:       env.MustGet("POSTGRES_HOST"),
		Port:       env.MustGet("POSTGRES_PORT"),
		User:       env.MustGet("POSTGRES_USER"),
		Password:   env.MustGet("POSTGRES_PASSWORD"),
		Name:       env.MustGet("POSTGRES_DB"),
		Migrations: env.MustGet("POSTGRES_MIGRATIONS"),
	}
}
