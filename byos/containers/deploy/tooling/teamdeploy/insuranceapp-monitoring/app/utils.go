package main

import (
	"time"
	"math/rand"
	"fmt"
)

func randomSleep(maxTimeToSleep int) {
	timeToSleep := rand.Intn(maxTimeToSleep)
	time.Sleep(time.Second * time.Duration(timeToSleep))
}

func logger(message string){
	if (*shouldlog){
		fmt.Println(message)
	}
}