package configs

import "github.com/sharpvik/log-go"

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
		Host:       mustGet("POSTGRES_HOST"),
		Port:       mustGet("POSTGRES_PORT"),
		User:       mustGet("POSTGRES_USER"),
		Password:   mustGet("POSTGRES_PASSWORD"),
		Name:       mustGet("POSTGRES_DB"),
		Migrations: mustGet("POSTGRES_MIGRATIONS"),
	}
}
