package main

import (
	"flag"
	"fmt"
	"math/rand"
	"os"
	"time"
)

var (
	shouldlog = flag.Bool("log", false, "should log to standard out (use for debugging)")
)

func main() {
	flag.Usage = func() {
		fmt.Fprintf(os.Stderr, "Usage:\n")
		flag.PrintDefaults()
	}

	cpuDurationMax := flag.Int("cpu-duration-max", 10, "maximum time in seconds the cpu will run at full capacity")
	cpuSleepMax := flag.Int("cpu-sleep-max", 60, "maximum time in seconds the cpu will sleep")

	memoryConsumptionGoal := flag.Int("memory-consumption-goal", 5, "GB to be consumed within timeframe")
	memoryConsumptionTimeframe := flag.Int("memory-consumption-timeframe", 300, "time in seconds to reach consumption goal")
	memorySleepLength := flag.Int("memory-sleep-length", 30, "time in seconds to sleep between memory consumption cycles")

	fileConsumptionMax := flag.Int("file-consumption-max", 5, "maximum number of GB of files to consume each time")
	fileSleepMax := flag.Int("file-sleep-max", 60, "maximum time in seconds file consumption will sleep before consuming more")
	numberOfChunks := flag.Int("file-chunk-number", 10, "number of chunks to break write into")

	disableFiles := flag.Bool("disable-files", false, "")
	disableMemory := flag.Bool("disable-memory", false, "")
	disableCPU := flag.Bool("disable-cpu", false, "")

	flag.Parse()
	fmt.Println("Processing started.")

	rand.Seed(time.Now().UnixNano())

	stopCh := make(chan struct{})

	go startServer()

	if !*disableMemory {
		go startMemory(*memoryConsumptionGoal, *memoryConsumptionTimeframe, *memorySleepLength)
	} else {
		fmt.Println("Memory disabled.")
	}

	if !*disableCPU {
		go startCPU(*cpuDurationMax, *cpuSleepMax)
	} else {
		fmt.Println("CPU disabled.")
	}

	if !*disableFiles {
		go startFiles(*fileConsumptionMax, *fileSleepMax, *numberOfChunks)
	} else {
		fmt.Println("Files disabled.")
	}

	<-stopCh
}
