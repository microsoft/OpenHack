package main

import (
	"fmt"
	"net/http"
	"log"
	"math/rand"
)

func startServer(){
	http.HandleFunc("/", func (w http.ResponseWriter, r *http.Request) {
		calculation := rand.Float64() * 1000
		
		fmt.Fprintln(w, fmt.Sprintf("Your new calculation is: %f", calculation))
	})
	
	fmt.Println("Starting Webserver...")
	log.Fatal(http.ListenAndServe(":8081", nil))
}