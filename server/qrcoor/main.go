package main

import (
	"log"
	"qrcoor/config"
	"qrcoor/librarian"
	"qrcoor/server"
)

func main() {
	config.LoadConfig("config.json")
	librarian.Init()
	err := server.RunServer()
	if err != nil {
		log.Println(err)
	}
}
