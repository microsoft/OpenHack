package main

import (
	"time"
	"math/rand"
	"math"
	"fmt"
)

func startCPU (cpuDurationMax int, cpuSleepMax int) {
	for {
		timeToUseCPU := rand.Intn(cpuDurationMax)
		duration := time.Second * time.Duration(timeToUseCPU)
		start := time.Now()
		logger(fmt.Sprintf("starting cpu for %d seconds...",timeToUseCPU))
		for time.Since(start) < duration {
			useCPU()
		}

		logger(fmt.Sprintf("done with cpu sleeping for %d seconds...", cpuSleepMax))
		randomSleep(cpuSleepMax)
	}	
}

func useCPU(){
	for i := 1; i < 10000000; i++ {
		x := 0.0
		x += math.Sqrt(0)
	}
}