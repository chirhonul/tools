package main

import (
	"net/http"
	"log"
	"os"
)

func main() {
	dir := os.Getenv("FILESERVER_DIR")
	if dir == "" {
		dir = "/var/www"
	}
	addr := os.Getenv("FILESERVER_ADDR")
	if addr == "" {
		addr = ":80"
	}
	fs := http.FileServer(http.Dir(dir))
	http.Handle("/", fs)
	s := &http.Server{Addr: addr}
	log.Fatal(s.ListenAndServe())
}
