package main

import (
	"fmt"
	"os"
	"strings"
)

func startFiles(fileConsumptionMax int, fileSleepMax int, chunks int) {
	logger(fmt.Sprintf("Start logging %d GB files in %d chunks...", fileConsumptionMax, chunks))

	for {
		s := strings.Repeat("1", 1024*1024*1024*fileConsumptionMax / chunks)

		f, err := os.OpenFile("/tmp/log", os.O_APPEND|os.O_WRONLY|os.O_CREATE, 0644)
		if err != nil {
			fmt.Printf("error: %s\n", err)
		}
		defer f.Close()

		written :=0
		for i := 0; i < chunks; i++ {
			logger(fmt.Sprintf("writing %d bytes chunk....", len(s)))
			n, err := f.WriteString(s)
			if err != nil {
				fmt.Printf("Error writing to file at /tmp/log: %s\n", err)
				fmt.Printf("To pass challenge disable files by passing flag --disable-files to deployment: %s\n", err)
				fmt.Printf("It is also possible to enable higher fidelity monitoring via  --log: %s\n", err)
			}	
			
			logger(fmt.Sprintf("wrote %d bytes chunk", n))
			written = written + n
		}
		
		logger(fmt.Sprintf("Finished writing total of %d bytes", written))

		randomSleep(fileSleepMax)
	}
}
