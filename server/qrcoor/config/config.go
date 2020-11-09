package config

import (
	"encoding/json"
	"log"
	"os"
)

type GConfig struct {
	CacheTimeMinutes int
	HostName         []string
	CacheDir         string

	Port           string
	ProductionMode bool
	TLS            bool
}

var GlobalConfig GConfig

func LoadConfig(filename string) {
	GlobalConfig = ParseConfig(filename)
}

func ParseConfig(filename string) GConfig {
	f, err := os.Open(filename)
	if err != nil {
		log.Fatalln(err)
	}
	var config GConfig
	decoder := json.NewDecoder(f)
	err = decoder.Decode(&config)
	if err != nil {
		log.Fatalln(err)
	}
	log.Printf("%+v\n", config)
	return config
}
