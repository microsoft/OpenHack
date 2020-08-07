package main

import (
	"fmt"
	"math"
	"runtime"
	"time"
)

func startMemory(memoryConsumptionGoal int, memoryConsumptionTimeframe int, memorySleepLength int) {
	logger("Start logging memory...")

	cycles := memoryConsumptionTimeframe / memorySleepLength

	var memToEat float64
	if cycles < 30 {
		memToEat = float64(memoryConsumptionGoal) * math.Exp2(float64(30-cycles))
	} else {
		memToEat = float64(memoryConsumptionGoal) * math.Exp2(float64(1))
	}

	var memory [][]int
	for {
		a := make([]int, 0, int(memToEat))
		memory = append(memory, a)
		memToEat *= 2

		time.Sleep(time.Second * time.Duration(memorySleepLength))
		printMemoryUsage()
	}
}

func printMemoryUsage() {
	var m runtime.MemStats
	runtime.ReadMemStats(&m)
	logger(fmt.Sprintf("Memory currently allocated = %v Mib", m.Alloc/1024/1024))
}
