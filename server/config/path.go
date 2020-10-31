package config

import (
	"encoding/json"
	"log"
	"os"
)

var Path struct {
	Public string
}

func init() {
	log.Print("config path")

	file, err := os.Open("path.json")
	if err != nil {
		log.Fatal("failed to load path")
	}

	err = json.NewDecoder(file).Decode(&Path)
	if err != nil {
		log.Fatal("failed to read path")
	}
}
